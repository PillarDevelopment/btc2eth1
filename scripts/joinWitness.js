const Btc2eth1 = artifacts.require('./Btc2eth1.sol')
const GovEngine = artifacts.require('./GovEngine.sol');
const Token = artifacts.require('./Token.sol')

module.exports = async function (callback) {

    let from = process.env.FROM

    const ge = await GovEngine.deployed()

    const gov = await Token.at(await ge.getGov());

    let balance = await gov.balanceOf(from)

    await gov.approve(ge.address, web3.utils.toWei('50000', 'ether'))

    await ge.deposit(web3.utils.toWei('50000', 'ether'))

    let deposited = await ge.balanceOf(from)

    console.log(deposited.toString())



}

function joinGroup(args) {
    log(args, btc2eth1)
}

function log(msg, contract) {
    // const log = `${new Date()} Contract: ${contract.address} msg: ${message} @${contract.name}`
    const log = `${new Date().toLocaleString()} msg: ${msg} @${contract.contractName}`
    console.log(log)
}