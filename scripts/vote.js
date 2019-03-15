const GovEngine = artifacts.require('./GovEngine.sol');
const Token = artifacts.require('./Token.sol')

module.exports = async function (callback) {

    let from = process.env.FROM

    const ge = await GovEngine.deployed()

    const gov = await Token.at(await ge.getGov());

    await gov.approve(ge.address, web3.utils.toWei('50000', 'ether'), {
        from: from
    })

    await ge.deposit(web3.utils.toWei('50000', 'ether'), {
        from: from
    })

    let deposited = await ge.balanceOf(from)

    console.log(deposited.toString())
}