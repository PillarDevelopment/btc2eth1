const StakeManager = artifacts.require('./StakeManager.sol');
const Token = artifacts.require('./Token.sol')

module.exports = async function (callback) {

    const from = process.env.FROM

    const sm = await StakeManager.deployed()

    const gov = await Token.at(await sm.getGov());

    await gov.approve(sm.address, web3.utils.toWei('50000', 'ether'), {
        from: from
    })

    await sm.deposit(web3.utils.toWei('50000', 'ether'), {
        from: from
    })

    let deposited = await sm.getStake(from)

    console.log(deposited.toString())

    callback()
}