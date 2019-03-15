const Token = artifacts.require("./Token.sol");
const StakeManager = artifacts.require("./StakeManager.sol")
const Btc2eth1 = artifacts.require("./Btc2eth1.sol")

const BN = web3.utils.BN;

module.exports = function (deployer, net, accounts) {
    if (net == 'development') {
        return true
    }
    let gov;
    let btct;
    let sm;

    let decimals = 18
    let mintValue = web3.utils.toWei(new BN('120000000'), 'ether')
    deployer.deploy(Token, "Test GOV token", "GOV", decimals, mintValue, {
        from: accounts[0]
    }).then(async (_gov) => {
        gov = _gov
        await gov.transfer(accounts[1], web3.utils.toWei('600000', 'ether'))
        await gov.transfer(accounts[2], web3.utils.toWei('600000', 'ether'))
        await gov.transfer(accounts[3], web3.utils.toWei('600000', 'ether'))
        return deployer.deploy(Token, "Test btct token", "tBTCT", decimals, 0, {
            from: accounts[0]
        })
    }).then((_btct) => {
        btct = _btct
        return deployer.deploy(StakeManager, gov.address, {
            from: accounts[0]
        })
    }).then((_sm) => {
        sm = _sm
        return deployer.deploy(Btc2eth1, btct.address, sm.address, {
            from: accounts[0]
        })
    })
}