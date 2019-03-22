const StakeManager = artifacts.require('./StakeManager.sol');



module.exports = async function (callback) {

    let from = process.env.FROM

    const sm = await StakeManager.deployed()

    const period = Math.floor(Date.now() / 1000) + 604900

    const actor = process.env.ACTOR

    let deposited = await sm.getStake(from)

    console.log(deposited)

    let voted = await sm.finalize(true, true, actor, period, from)


    console.log(voted)

}