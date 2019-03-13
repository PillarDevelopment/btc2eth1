const Token = artifacts.require("./Token.sol");
const BN = web3.utils.BN;

module.exports = function (deployer, net, accounts) {
    if (net == 'development') {
        return true
    }
    let decimals = 18
    let mintValue = web3.utils.toWei(new BN('40000'), 'ether')
    deployer.deploy(Token, "Test token", "TKG", decimals, mintValue, {
        from: accounts[0]
    }).then(async () => {
        instance = await Token.deployed()
    });

};