const Token = artifacts.require('Token');
const GovEngine = artifacts.require('GovEngine');
const BN = web3.utils.BN;
const ethutil = require('ethereumjs-util')

contract('GovEngineTest', async (accounts) => {
    it('deposit', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let gov = await Token.new("Test token", "GOV", decimals, mintValue)

        let ge = await GovEngine.new(gov.address)

        let from = accounts[0];
        let amount = web3.utils.toWei(new BN('20'), 'ether')

        let balanceFrom = await gov.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        await gov.approve(ge.address, amount)

        await ge.deposit(amount, {
            from: from
        });

        let stakedBalance = await ge.getStake(from);
        let updateBalanceFrom = await gov.balanceOf(from);

        assert.equal(amount.toString(), stakedBalance.toString());
        assert.equal(balanceFrom.sub(amount).toString(), updateBalanceFrom.toString());
    });

    it('deposit by tranferMetaTx', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let gov = await Token.new("Test token", "GOV", decimals, mintValue)
        let ge = await GovEngine.new(gov.address)

        let from = accounts[0];

        let balanceFrom = await gov.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        let to = ge.address
        let amount = web3.utils.toWei(new BN('20'), 'ether')
        let nonce = (await gov.getNonce(from)).add(new BN("1"))
        // set gas price 2 Gwei
        let gasPrice = web3.utils.toWei(new BN('4'), 'Gwei')
        // set gas limit 200000
        let gasLimit = web3.utils.toWei(new BN('200000'), 'wei')
        // set token price = 1 ether  
        let tokenPrice = web3.utils.toWei(new BN('100'), 'finney')
        let relayer = accounts[2];
        let fromPrivKey = Buffer.from(String(process.env.FROM_PRIVKEY.slice(2)), 'hex')
        let tokenReceiver = accounts[3]

        let hash = await gov.getTransactionHash.call(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            relayer,
            tokenReceiver
        );
        let message = ethutil.hashPersonalMessage(Buffer.from(hash.slice(2), 'hex'));
        let rsv = ethutil.ecsign(message, fromPrivKey)
        let sig = [
            ethutil.bufferToHex(rsv.r),
            ethutil.bufferToHex(rsv.s).slice(2),
            ethutil.bufferToHex(rsv.v).slice(2)
        ].join('')
        //console.log(sig)
        let transfer = await gov.transferMetaTx(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            relayer,
            tokenReceiver,
            sig, {
                from: relayer,
                gasPrice: gasPrice
            });
        let depositFrom = await ge.getStake(from);

        assert.equal(depositFrom.toString(), amount);

    });
    it('submit proposal', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('4000000'), 'ether')
        let gov = await Token.new("Test token", "GOV", decimals, mintValue)

        let ge = await GovEngine.new(gov.address)

        let candidate = accounts[0]
        let submitter = accounts[1]

        await gov.transfer(submitter, web3.utils.toWei('150000', 'ether'))

        await gov.approve(ge.address, web3.utils.toWei('50000', 'ether'), {
            from: candidate
        })

        await ge.deposit(web3.utils.toWei('50000', 'ether'), {
            from: candidate
        })

        await gov.approve(ge.address, web3.utils.toWei('50000', 'ether'), {
            from: submitter
        })

        await ge.deposit(web3.utils.toWei('50000', 'ether'), {
            from: submitter
        })
        const period = Math.floor(Date.now() / 1000)

        let submit = await ge.submitProposal(true, true, candidate, period)
    })
});