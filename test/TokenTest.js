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

        let balanceFrom = await token.balanceOf(from);

        assert.equal(balanceFrom.toString(), mintValue.toString());

        let to = accounts[1];
        let amount = web3.utils.toWei(new BN('20'), 'ether')
        let nonce = (await token.getNonce(from)).add(new BN("1"))
        let gasPrice = web3.utils.toWei(new BN('20'), 'Gwei').add(new BN('1'))
        let gasLimit = web3.utils.toWei(new BN('200000'), 'wei')
        let gasTokenPerWei = web3.utils.toWei(new BN('200'), 'wei')
        let relayer = accounts[2];
        let relayerkey = Buffer.from("1ff778cc3880932d4cbf83f1a8b2eb013b8189f4f6a787a24e22b444d59a329a", 'hex')
        let tokenReceiver = accounts[3]

        let hash = await token.getTransactionHash.call(
            from,
            to,
            amount,
            [gasPrice, gasLimit, gasTokenPerWei, nonce],
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
        console.log(sig)
        let transfer = await token.transferMetaTx(
            from,
            to,
            amount,
            [gasPrice, gasLimit, gasTokenPerWei, nonce],
            relayer,
            tokenReceiver,
            sig, {
                from: relayer,
                gasPrice: gasPrice
            });
    });
});