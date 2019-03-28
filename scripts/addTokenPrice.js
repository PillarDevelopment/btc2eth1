const Token = artifacts.require('./Token.sol');

module.exports = async function (callback) {

    let from = process.env.FROM

    const btct = await Token.at("0x45E9932fD308346CB9157F8bF5937437Bf39BB4C")

    const amount = web3.utils.toWei('0.1', 'ether')

    let set = await btct.setEstimateTokenPrice(amount, {
        from: from
    })

    console.log(set)

}