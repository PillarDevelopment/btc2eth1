const Token = artifacts.require('Token');
const GovEngine = artifacts.require('GovEngine');
const BN = web3.utils.BN;
const ethutil = require('ethereumjs-util')

contract('GovEngineTest', async (accounts) => {
    it('deposit', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let token = await Token.new("Test token", "TKG", decimals, mintValue)

        let gov = await GovEngine.new(token.address)

        let from = accounts[0];
        let amount = web3.utils.toWei(new BN('20'), 'ether')

        let balanceFrom = await token.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        await token.approve(gov.address, amount)

        await gov.deposit(amount, {
            from: from
        });

        let stakedBalance = await gov.balanceOf(from);
        let updateBalanceFrom = await token.balanceOf(from);

        assert.equal(amount.toString(), stakedBalance.toString());
        assert.equal(balanceFrom.sub(amount).toString(), updateBalanceFrom.toString());
    });

    it('deposit by tranferMetaTx', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let token = await Token.new("Test token", "TKG", decimals, mintValue)
        let gov = await GovEngine.new(token.address)

        let from = accounts[0];

        let balanceFrom = await token.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        let to = gov.address
        let amount = web3.utils.toWei(new BN('20'), 'ether')
        let nonce = (await token.getNonce(from)).add(new BN("1"))
        // set gas price 2 Gwei
        let gasPrice = web3.utils.toWei(new BN('4'), 'Gwei')
        // set gas limit 200000
        let gasLimit = web3.utils.toWei(new BN('200000'), 'wei')
        // set token price = 1 ether  
        let tokenPrice = web3.utils.toWei(new BN('100'), 'finney')
        let relayer = accounts[2];
        let relayerkey = Buffer.from("1ff778cc3880932d4cbf83f1a8b2eb013b8189f4f6a787a24e22b444d59a329a", 'hex')
        let tokenReceiver = accounts[3]

        let hash = await token.getTransactionHash.call(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            relayer,
            tokenReceiver
        );
        let message = ethutil.hashPersonalMessage(Buffer.from(hash.slice(2), 'hex'));
        let rsv = ethutil.ecsign(message, relayerkey)
        let sig = [
            ethutil.bufferToHex(rsv.r),
            ethutil.bufferToHex(rsv.s).slice(2),
            ethutil.bufferToHex(rsv.v).slice(2)
        ].join('')
        //console.log(sig)
        let transfer = await token.transferMetaTx(
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
    });
});