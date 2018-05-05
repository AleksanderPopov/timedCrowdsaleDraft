var Campaign = artifacts.require("./Campaign.sol");
var SpendBallot = artifacts.require("./SpendBallot.sol");

const hardCap = web3.toWei(10, 'ether');
const minInvest = web3.toWei(0.5, 'ether');
const year = 2018;
const month = 5;
const day = 25;

module.exports = function (deployer) {
    deployer.deploy(Campaign, hardCap, minInvest, year, month, day);
    deployer.deploy(SpendBallot);
};
