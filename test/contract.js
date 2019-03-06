contract('contract', function(accounts) {
  it("should assert true", function(done) {
    var contract = contract.deployed();
    assert.isTrue(true);
    done();
  });
});
