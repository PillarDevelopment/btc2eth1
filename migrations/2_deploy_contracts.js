const Token = artifacts.require("./Token.sol");
const StakeManager = artifacts.require("./StakeManager.sol")
const Btc2eth1 = artifacts.require("./Btc2eth1.sol")

const BN = web3.utils.BN;

module.exports = async function (deployer, net, accounts) {
    if (net == 'development') {
        return true
    }
    let decimals = 18
    let mintValue = web3.utils.toWei(new BN('120000000'), 'ether')

    try {
        const gov = await Token.new("Test GOV token", "GOV", decimals, mintValue)

        console.log('gov', gov.address)

        await gov.transfer(accounts[1], web3.utils.toWei('600000', 'ether'))
        await gov.transfer(accounts[2], web3.utils.toWei('600000', 'ether'))
        await gov.transfer(accounts[3], web3.utils.toWei('600000', 'ether'))

        const btct = await Token.new("Test btct token", "tBTCT", decimals, 0)

        console.log('btct', btct.address)

        await deployer.deploy(StakeManager, gov.address, {
            from: accounts[0]
        })

        const sm = await StakeManager.deployed()

        await deployer.deploy(Btc2eth1, btct.address, sm.address, 3, {
            from: accounts[0]
        })

    } catch (err) {
        console.log(err)
    }
}