const ERC20HashPay = artifacts.require('./ERC20HashPay.sol');
const ethutil = require('ethereumjs-util')
const crypto = require('crypto')

contract('ERC20HashPay', function (accounts) {
    it("should assert true", async function (done) {
        const hashpay = await ERC20HashPay.new("TestToken", "TST", 18);

        const payer = accounts[0]
        console.log(`payer = ${payer} contract = ${hashpay.address}`)
        // payer set new hash to lasthash
        let secrets = createSecret(20)

        let onions = createHashOnion(secrets)

        let last = onions.pop()


        let store = await hashpay.addLatest('0x' + last.lastHash, {
            from: payer
        })
        console.log(`stored lasthash = ${payer} lastHash = ${last.lastHash}`)

        let latest = await hashpay.getLatest.call(payer)

        console.log(`getLatest(payer) = ${latest} prev = ${last.prev} hash = ${last.lastHash} secret = ${last.secret}`)

        let prevHash = last.prev

        let prevSecret = last.secret

        let two = onions.pop()

        let hash = createTxHash(
            payer,
            accounts[1],
            ethutil.bufferToHex(ethutil.setLengthLeft(300, 32)),
            "0x" + prevHash,
            "0x" + prevSecret
        )

        let hash2 = createTxHash(
            payer,
            accounts[1],
            ethutil.bufferToHex(ethutil.setLengthLeft(300, 32)),
            "0x" + two.prev,
            "0x" + two.secret
        )        
        console.log(hash, hash2)
        // from relayer
        let attachTx = await hashpay.addStream('0x' + hash)

        let attachTx2 = await hashpay.addStream('0x' + hash2)

        let old = await hashpay.getStream.call()

        // add stream
        let stream = await hashpay.getStream.call()

        console.log(`Attached Transaction attachTx: ${hash} stream = ${stream} prev = ${old}`)

        let tranfer = await hashpay.settle(
            [payer, payer],
            [accounts[1], accounts[1]],
            [300,300],
            ['0x' + prevHash, '0x' + two.prev],
            ['0x' + prevSecret, '0x' + two.secret]
        )

        console.log(tranfer)
        //done();
    });

    function createSecret(count) {
        let array = []
        for (i = 0; i <= count; i++) {
            array.push(crypto.randomBytes(32).toString('hex'))
        }
        return array
    }

    function createHashOnion(_secrets) {
        let lastHash = new Buffer(32);
        let data = []
        _secrets.forEach((_secret) => {
            let prev = lastHash
            let encoded = Buffer.from(prev.toString('hex') + _secret, 'hex')
            lastHash = ethutil.keccak256(encoded)
            //console.log(`prev = ${prev.toString('hex')} next = ${lastHash.toString('hex')} secret = ${_secret.toString('hex')}`)
            data.push({
                prev: prev.toString('hex'),
                lastHash: lastHash.toString('hex'),
                secret: _secret.toString('hex')
            })
        })
        return data;
    }

    function createTxHash(_from, _to, _amount, _prev, _secret) {
        let from = _from.slice(2)
        let to = _to.slice(2)
        let amount = _amount.slice(2)
        let encoded = Buffer.from(String(from + to + amount + _prev.slice(2) + _secret.slice(2)), 'hex')
        let hash = ethutil.keccak256(encoded).toString('hex')
        console.log(_from, _to, _amount, _prev, _secret, encoded.toString('hex'))
        //console.log(`hash = ${hash}`)
        return hash
    }
});