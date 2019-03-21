const Token = artifacts.require('Token');
const BN = web3.utils.BN;
const ethutil = require('ethereumjs-util')

contract('Token', async (accounts) => {
    it('transfer', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let token = await Token.new("Test token", "TKG", decimals, mintValue)

        let from = accounts[0];
        let to = accounts[1];
        let amount = web3.utils.toWei(new BN('20'), 'ether')

        let balanceFrom = await token.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        let balanceTo = await token.balanceOf(to);

        let transfer = await token.transfer(to, amount, {
            from: from
        });

        let updateBalanceFrom = await token.balanceOf(from);
        let updateBalanceTo = await token.balanceOf(to);

        assert.equal(mintValue.sub(amount).toString(), updateBalanceFrom.toString());
        assert.equal(balanceTo.add(amount).toString(), updateBalanceTo.toString());
    });

    it('tranferMetaTx', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let token = await Token.new("Test token", "TKG", decimals, mintValue)
        let from = accounts[0];
        let to = accounts[1];

        let balanceTo = await token.balanceOf(to);

        assert.equal(balanceTo.toString(), "0");

        // sending 20 token
        let amount = web3.utils.toWei(new BN('20'), 'ether')
        // nonce update
        let nonce = (await token.getNonce(from)).add(new BN("1"))
        // set gas price 2 Gwei
        let gasPrice = web3.utils.toWei(new BN('4'), 'Gwei')
        // set gas limit 200000
        let gasLimit = web3.utils.toWei(new BN('200000'), 'wei')
        // set token price = 1 ether  
        let tokenPrice = web3.utils.toWei(new BN('100'), 'finney')
        let relayer = accounts[2];
        let fromPrivKey = Buffer.from(String(process.env.FROM_PRIVKEY.slice(2)), 'hex')
        let tokenReceiver = accounts[3]

        let hash = await token.getTransactionHash.call(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            [relayer, tokenReceiver]
        );
        let message = ethutil.hashPersonalMessage(Buffer.from(hash.slice(2), 'hex'));
        let rsv = ethutil.ecsign(message, fromPrivKey)

        let v = ethutil.bufferToHex(rsv.v)
        let r = ethutil.bufferToHex(rsv.r)
        let s = ethutil.bufferToHex(rsv.s)
        //console.log(sig)
        console.log(
            from,
            to,
            amount.toString(),
            gasPrice.toString(),
            gasLimit.toString(),
            tokenPrice.toString(),
            nonce.toString(),
            relayer, tokenReceiver, v, r, s)

        await token.transferMetaTx(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            [relayer, tokenReceiver],
            v,
            r,
            s, {
                from: relayer,
                gasPrice: gasPrice
            });

        let updateBalanceTo = await token.balanceOf(to);
        let updateBalanceReceiver = await token.balanceOf(tokenReceiver)

        console.log(updateBalanceReceiver.toString() / 1e18)

        assert.equal(balanceTo.add(amount).toString(), updateBalanceTo.toString());
    });
    it('Contract paused', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let token = await Token.new("Test token", "TKG", decimals, mintValue)

        let from = accounts[0];

        let balanceFrom = await token.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        await token.setPaused(true)

        let to = accounts[1];
        let amount = web3.utils.toWei(new BN('20'), 'ether')

        await token.transfer(to, amount, {
            from: from
        }).catch((err) => {
            assert.isObject(err, "passed")
        });

        await token.approve(to, amount, {
            from: from
        }).catch((err) => {
            assert.isObject(err, "passed")
        });

        await token.increaseAllowance(to, amount, {
            from: from
        }).catch((err) => {
            assert.isObject(err, "passed")
        });
        await token.decreaseAllowance(to, amount, {
            from: from
        }).catch((err) => {
            assert.isObject(err, "passed")
        });

        await token.mint(to, amount, {
            from: from
        }).catch((err) => {
            assert.isObject(err, "passed")
        });

        // nonce update
        let nonce = (await token.getNonce(from)).add(new BN("1"))
        // set gas price 2 Gwei
        let gasPrice = web3.utils.toWei(new BN('4'), 'Gwei')
        // set gas limit 200000
        let gasLimit = web3.utils.toWei(new BN('200000'), 'wei')
        // set token price = 1 ether  
        let tokenPrice = web3.utils.toWei(new BN('100'), 'finney')
        let relayer = accounts[2];
        let fromPrivKey = Buffer.from(String(process.env.FROM_PRIVKEY.slice(2)), 'hex')
        let tokenReceiver = accounts[3]

        let hash = await token.getTransactionHash.call(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            [relayer, tokenReceiver]
        );
        let message = ethutil.hashPersonalMessage(Buffer.from(hash.slice(2), 'hex'));
        let rsv = ethutil.ecsign(message, fromPrivKey)

        let v = ethutil.bufferToHex(rsv.v)
        let r = ethutil.bufferToHex(rsv.r)
        let s = ethutil.bufferToHex(rsv.s)

        await token.transferMetaTx(
            from,
            to,
            amount,
            [gasPrice, gasLimit, tokenPrice, nonce],
            [relayer, tokenReceiver],
            v,
            r,
            s, {
                from: relayer,
                gasPrice: gasPrice
            }

        ).catch((err) => {
            assert.isObject(err, "passed")
        });
    })
    it('token mint', async () => {
        let decimals = 18
        let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
        let token = await Token.new("Test token", "TKG", decimals, mintValue)

        let from = accounts[0];
        let amount = web3.utils.toWei(new BN('20'), 'ether')

        let balanceFrom = await token.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        await token.mint(from, amount, {
            from: from
        });

        await token.mint(from, amount, {
            from: accounts[2]
        }).catch((err) => {
            assert.isObject(err, "passed")
        });

        let updateBalanceFrom = await token.balanceOf(from);

        assert.equal(balanceFrom.add(amount).toString(), updateBalanceFrom.toString());
    });
})