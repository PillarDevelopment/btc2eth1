
const ERC20HashPay = artifacts.require("./ERC20HashPay.sol");

module.exports = function(deployer) {
  deployer.deploy(ERC20HashPay, "token sample", "STG", 18);
};
