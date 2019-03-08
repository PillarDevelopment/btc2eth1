const Token = artifacts.require('./Token.sol');
const ethutil = require('ethereumjs-util')
const crypto = require('crypto')

contract('Token', function (accounts) {
    it("should assert true", async function (done) {
        hashpay = await Token.new();

        const mint = await hashpay.init("Test token", "TKG", 18);

        const payer = accounts[0]
        console.log(`payer = ${payer} contract = ${hashpay.address}`)
        // payer set new hash to lasthash
        let secrets = createSecret(20)

        let onions = createHashOnion(secrets)

        let one = onions.pop()

        let stored = await hashpay.addLatest('0x' + one.lastHash, {
            from: payer
        })
        console.log(`stored lasthash = ${payer} lastHash = ${one.lastHash}`)

        let latest = await hashpay.getLatest.call(payer)

        console.log(`getLatest(payer) = ${latest} prev = ${one.prev} hash = ${one.lastHash} secret = ${one.secret}`)


        payers = []
        receivers = []
        amounts = []
        prevs = []
        secretlists = []

        let tx1 = await createTx(one, payer, accounts[2], 300)

        console.log("1", "prev", one.prev, one.secret)

        let two = onions.pop()

        let tx2 = await createTx(two, payer, accounts[1], 400)

        let three = onions.pop()

        //let tx3 = await createTx(three, payer, accounts[3], 200)

        console.log("2", "prev", two.prev, two.secret)

        pushTx(payer, accounts[2], 300, '0x' + one.prev, '0x' + one.secret)

        pushTx(payer, accounts[1], 400, '0x' + two.prev, '0x' + two.secret)

        //pushTx(payer, accounts[3], 200, '0x' + three.prev, '0x' + three.secret)

        let newStream1 = await hashpay.getStream()

        console.log(`
            getStream, ${newStream1}
        `)

        let balance = await hashpay.balanceOf(accounts[0])

        console.log(balance.toNumber())

        let settled = await hashpay.getSettled()

        console.log('settled', settled, receivers)
        let tranfer = await hashpay.settle(payers, receivers, amounts, prevs, secretlists, {
            gas: 400000
        })
        console.log(tranfer)

        let newStream = await hashpay.getStream()

        console.log(`
            newStream, ${newStream}
        `)
        let latest2 = await hashpay.getLatest.call(payer)

        tranfer.logs.forEach((log) => {
            console.log("lastsettled", log.args.lastSettled)
        })

        let settled2 = await hashpay.getSettled()
        console.log(`
            settled2, ${settled2}
        `)
        done();
    });

    function pushTx(payer, to, amount, prev, secret) {
        payers.push(payer)
        receivers.push(to)
        amounts.push(amount)
        prevs.push(prev)
        secretlists.push(secret)
    }

    function createTx(onion, payer, to, amount) {
        return new Promise(async (resolve, reject) => {
            let hash = createTxHash(
                payer,
                to,
                ethutil.bufferToHex(ethutil.setLengthLeft(amount, 32)),
                "0x" + onion.prev,
                "0x" + onion.secret
            )
            let attachTx = await hashpay.addStream('0x' + hash)
            let stream = await hashpay.getStream.call()
            return resolve({
                hash: hash,
                prev: onion.prev,
                secret: onion.secret,
                stream: stream
            });
        })

    }

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
        //console.log(_from, _to, _amount, _prev, _secret, encoded.toString('hex'))
        //console.log(`hash = ${hash}`)
        return hash
    }
});