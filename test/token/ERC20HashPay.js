
const ERC20HashPay = artifacts.require('./ERC20HashPay.sol');

contract('ERC20HashPay', function(accounts) {
  it("should assert true", function(done) {
    var iERC20HashPay = ERC20HashPay.deployed();
    assert.isTrue(true);
    console.log(iERC20HashPay)
    done();
  });
});
