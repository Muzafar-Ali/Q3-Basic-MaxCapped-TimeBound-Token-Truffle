const CappedAndTimeBoundTokens = artifacts.require("CappedAndTimeBoundTokens");

module.exports = function (deployer) {
  deployer.deploy(CappedAndTimeBoundTokens);
};
