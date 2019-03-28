const Token = artifacts.require('Token');
const StakeManager = artifacts.require('StakeManager');
const BN = web3.utils.BN;
const ethutil = require('ethereumjs-util')

const jsonrpc = '2.0'
const id = 0
const send = (method, params = []) =>
    web3.currentProvider.send({
        id,
        jsonrpc,
        method,
        params
    }, (err, result) => {
        if (err)
            console.log(err)
    })
const timeTravel = async seconds => {
    await send('evm_increaseTime', [seconds])
    await send('evm_mine')
}

contract('StakeManagerTest', async (accounts) => {
    it('deposit', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let gov = await Token.new("Test token", "GOV", decimals, mintValue)

        let sm = await StakeManager.new(gov.address)

        let from = accounts[0];
        let amount = web3.utils.toWei(new BN('20'), 'ether')

        let balanceFrom = await gov.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        await gov.approve(sm.address, amount)

        await sm.deposit(amount, {
            from: from
        });

        let stakedBalance = await sm.getStake(from);
        let updateBalanceFrom = await gov.balanceOf(from);

        assert.equal(amount.toString(), stakedBalance.toString());
        assert.equal(balanceFrom.sub(amount).toString(), updateBalanceFrom.toString());
    });

    it('deposit by tranferMetaTx', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let gov = await Token.new("Test token", "GOV", decimals, mintValue)
        let sm = await StakeManager.new(gov.address)

        let from = accounts[0];

        let balanceFrom = await gov.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        let to = sm.address
        let amount = web3.utils.toWei(new BN('20'), 'ether')
        let nonce = (await gov.getNonce(from)).add(new BN("1"))
        // set gas price 2 Gwei
        let gasPrice = web3.utils.toWei(new BN('4'), 'Gwei')
        // set gas limit 200000
        let gasLimit = web3.utils.toWei(new BN('200000'), 'wei')
        // set token price = 1 ether  
        let tokenPrice = web3.utils.toWei(new BN('100'), 'finney')
        let relayer = accounts[2];
        let fromPrivKey = Buffer.from(String(process.env.KEY.slice(2)), 'hex')
        let tokenReceiver = accounts[3]

        let hash = await gov.getTransactionHash.call(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            relayer
        );
        let message = ethutil.hashPersonalMessage(Buffer.from(hash.slice(2), 'hex'));
        let rsv = ethutil.ecsign(message, fromPrivKey)

        let v = rsv.v
        let r = ethutil.bufferToHex(rsv.r)
        let s = ethutil.bufferToHex(rsv.s)

        await gov.transferMetaTx(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            relayer,
            v,
            r,
            s,
            tokenReceiver, {
                from: relayer,
                gasPrice: gasPrice
            });

        let depositFrom = await sm.getStake(from);

        assert.equal(depositFrom.toString(), amount);

    });
    it('submit proposal', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('4000000'), 'ether')
        let gov = await Token.new("Test token", "GOV", decimals, mintValue)

        let sm = await StakeManager.new(gov.address)

        let candidate = accounts[0]
        let submitter = accounts[1]

        await gov.transfer(submitter, web3.utils.toWei('150000', 'ether'))

        await gov.approve(sm.address, web3.utils.toWei('50000', 'ether'), {
            from: candidate
        })

        await sm.deposit(web3.utils.toWei('50000', 'ether'), {
            from: candidate
        })

        await gov.approve(sm.address, web3.utils.toWei('50000', 'ether'), {
            from: submitter
        })

        await sm.deposit(web3.utils.toWei('50000', 'ether'), {
            from: submitter
        })
        const period = Math.floor(Date.now() / 1000) + 604900 + 300

        await sm.submitProposal(true, true, candidate, period, {
            from: submitter
        })

        let supply = await gov.totalSupply()
        let score = await sm.getScore()

        assert.equal(supply.toString(), score.toString());

    })
    it('vote', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('4000000'), 'ether')
        let gov = await Token.new("Test token", "GOV", decimals, mintValue)

        let sm = await StakeManager.new(gov.address)

        let candidate = accounts[0]
        let submitter = accounts[1]

        await gov.transfer(submitter, web3.utils.toWei('150000', 'ether'))

        await gov.approve(sm.address, web3.utils.toWei('50000', 'ether'), {
            from: candidate
        })

        await sm.deposit(web3.utils.toWei('50000', 'ether'), {
            from: candidate
        })

        await gov.approve(sm.address, web3.utils.toWei('50000', 'ether'), {
            from: submitter
        })

        await sm.deposit(web3.utils.toWei('50000', 'ether'), {
            from: submitter
        })
        const period = Math.floor(Date.now() / 1000) + 604900 + 300

        await sm.submitProposal(true, true, candidate, period, {
            from: submitter
        })

        let supply = await gov.totalSupply()

        let stake = await sm.getStake(candidate)

        await sm.vote(true)

        let score = await sm.getScore()

        assert.equal(supply.add(stake).toString(), score.toString());

        //console.log(vote, supply.add(stake).toString())
    })
    it('finalize', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('4000000'), 'ether')
        let gov = await Token.new("Test token", "GOV", decimals, mintValue)

        let sm = await StakeManager.new(gov.address)

        let candidate = accounts[0]
        let submitter = accounts[1]

        await gov.transfer(submitter, web3.utils.toWei('150000', 'ether'))

        await gov.approve(sm.address, web3.utils.toWei('50000', 'ether'), {
            from: candidate
        })

        await sm.deposit(web3.utils.toWei('50000', 'ether'), {
            from: candidate
        })

        await gov.approve(sm.address, web3.utils.toWei('50000', 'ether'), {
            from: submitter
        })

        await sm.deposit(web3.utils.toWei('50000', 'ether'), {
            from: submitter
        })
        const period = Math.floor(Date.now() / 1000) + 604900 + 300

        await sm.submitProposal(true, true, candidate, period, {
            from: submitter
        })

        let supply = await gov.totalSupply()

        let stake = await sm.getStake(candidate)

        await sm.vote(true)

        let score = await sm.getScore()

        assert.equal(supply.add(stake).toString(), score.toString());

        await timeTravel(604000)

        await sm.finalize(true, true, candidate, period, submitter, {
            from: submitter
        }).catch((err) => {
            assert.isObject(err, "correct")
        })

        await timeTravel(1900)

        await sm.finalize(true, true, candidate, period, submitter, {
            from: submitter
        })

        let finalizedScore = await sm.getScore()

        assert.equal(finalizedScore.toString(), "0");

        let isWitness = await sm.isValidWitnessConsortium(candidate)

        assert.equal(isWitness, true)
    })
});