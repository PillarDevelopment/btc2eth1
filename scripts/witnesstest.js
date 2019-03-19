const Btc2eth1 = artifacts.require('./Btc2eth1.sol')
const StakeManager = artifacts.require('./StakeManager.sol');

module.exports = async function (callback) {

    const btc2eth1 = await Btc2eth1.deployed()

    console.log(btc2eth1)
    const btc2eth1Event = btc2eth1.contract.allEvents({
        fromBlock: 0,
        toBlock: 'latest'
    })

    btc2eth1Event.watch(function (error, result) {
        if (error) return 0
        if (result.event == "JoinGroup")
            joinGroup(result.args)
        if (result.event == 'DepositedETH')
            UpdateWsh(result.args)

    })
}

function joinGroup(args) {
    log(args, btc2eth1)
}

function log(msg, contract) {
    // const log = `${new Date()} Contract: ${contract.address} msg: ${message} @${contract.name}`
    const log = `${new Date().toLocaleString()} msg: ${msg} @${contract.contractName}`
    console.log(log)
}