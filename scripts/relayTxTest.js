const Token = artifacts.require('./Token.sol')
const ethutil = require('ethereumjs-util')
const BN = require('bn.js');

module.exports = async function (callback) {

    let token = await Token.at("0x521F18B4d3c3c2Bc379d262AD70c8644A3f2A05b")

    let from = "0xd2330a9f6dDe4715F540D1669bf75E89a1b4FbBc"
    let to = "0x7D0344e0ee6bC3901F4b11b9d9b8D001b49872A1"

    let relayer = "0xb38f6C9d887b038038aa0272a4cd15c75B28E781"
    let tokenReceiver = "0xCC8690540faE802A251945556817D49a96990f44"

    // sending 20 token
    let amount = web3.utils.toWei(new BN('20'), 'ether')
    // nonce update
    let nonce = new BN("6")
    // set gas price 2 Gwei
    let gasPrice = web3.utils.toWei(new BN('4'), 'gwei')
    // set gas limit 200000
    let gasLimit = web3.utils.toWei(new BN('200000'), 'wei')
    // set token price = 1 ether  
    let tokenPrice = web3.utils.toWei(new BN('100'), 'finney')
    let fromPrivKey = Buffer.from(String(process.env.KEY.slice(2)), 'hex')

    let hash = await token.getTransactionHash.call(
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
    //console.log(sig)
    const data = {
        from: from,
        to: to,
        amount: amount.toString(),
        gasPrice: gasPrice.toString(),
        gasLimit: gasLimit.toString(),
        tokenPrice: tokenPrice.toString(),
        nonce: nonce.toString(),
        relayer: relayer,
        tokenReceiver: tokenReceiver,
        v: v,
        r: r,
        s: s
    }
    console.log(data)

}