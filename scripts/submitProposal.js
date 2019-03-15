const GovEngine = artifacts.require('./GovEngine.sol');

module.exports = async function (callback) {

    let from = process.env.FROM

    const ge = await GovEngine.deployed()

    const period = Math.floor(Date.now() / 1000)

    const actor = from

    let deposited = await ge.balanceOf(from)

    console.log(deposited.toString())

    let submited = await ge.submitProposal(true, true, actor, period)

    console.log(submited)
  
}