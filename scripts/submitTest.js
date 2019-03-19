const StakeManager = artifacts.require('./StakeManager.sol');

const jsonrpc = '2.0'
const id = 0
const send = (method, params = []) =>
    web3.currentProvider.send({
        id,
        jsonrpc,
        method,
        params
    }, (err, result) => {
        if (err)
            console.log(err)
    })
const timeTravel = async seconds => {
    await send('evm_increaseTime', [seconds])
    await send('evm_mine')
}

module.exports = async function (callback) {

    const from = process.env.FROM
    const actor = process.env.ACTOR

    const sm = await StakeManager.deployed()

    const period = Math.floor(Date.now() / 1000) + 604900

    let deposited = await sm.getStake(from)

    await sm.submitProposal(true, true, actor, period, {
        from: from
    })

    await sm.vote(true, {
        from: from
    })


    await timeTravel(604900)

    await sm.finalize(true, true, actor, period, from)

    callback()

}