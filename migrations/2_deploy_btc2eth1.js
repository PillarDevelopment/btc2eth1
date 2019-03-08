const Token = artifacts.require("./Token.sol");
//const ERC20Stakeable = artifacts.require("./ERC20Stakeable.sol")

module.exports = function (deployer, net, accounts) {
    if (net == 'development') {
        return true
    }
    deployer.deploy(Token, "Test token", "TKG", 18, {
        from: accounts[0]
    }).then(async () => {
        instance = await Token.deployed()
        //const mint = await instance.init("Test token", "TKG", 18);

        //const transfer = await instance.transfer(accounts[2], 122);
        //console.log(mint.logs[0], transfer.logs[0])
    });

};