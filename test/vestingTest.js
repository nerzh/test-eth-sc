const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545');

const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
chai.should();
const expect = chai.expect;
const assert = chai.assert;

const BigNumber = require('bignumber.js');
const {constants} = require('openzeppelin-test-helpers');
const { ethers } = require("ethers");
const truffleAssert = require('truffle-assertions');
const timeMachine = require("ganache-time-traveler");

/*eslint-disable no-undef*/
const Vesting = artifacts.require('Vesting');

BigNumber.config({ EXPONENTIAL_AT: 1e+9 });

describe("TestSet for vesting contract", () => {
  let deployer, user1, user2;

  let vesting;
  let snapshotId;

  before(async () => {
      [deployer, user1, user2] = await web3.eth.getAccounts();

      console.log(user1, user2);
      // token = await Vesting.new({ from: deployer });
      vesting = await Vesting.new();
  });
  
  describe("Simple test", () => {
      beforeEach(async () => {
          // Create a snapshot
          const snapshot = await timeMachine.takeSnapshot();
          snapshotId = snapshot["result"];
          // Deploy contract to ganache
          vesting = await Vesting.new();
      });

      afterEach(async () => await timeMachine.revertToSnapshot(snapshotId));

      it("Test set data", async () => {
        let amount = BigNumber(7 * 10**18);
        await vesting.setVesting(
            user1, 
            amount, 
            3, 
            5 * 60 * 1000,
            {from: deployer, value: amount}
        );
        let account = await vesting.accounts.call(user1);
        assert.isAtMost(Number(account.vestingStart), Number(Math.floor(Date.now() / 1000)));
        expect(String(account.amount)).to.equal(String(7 * 10**18));
        expect(String(account.parts)).to.equal(String(3));
        expect(String(account.accuracyInSeconds)).to.equal(String(5 * 60 * 1000));
        expect(String(account.withdrawn)).to.equal(String(0));
      });

      it("Test only Owner can set vesting", async () => {
        let error = 'This function is restricted to the contract\'s owner'
        await vesting.setVesting(
            user1,
            1, 
            1, 
            1,
            {from: user1, value: 1}
        ).should.be.rejectedWith(`Returned error: VM Exception while processing transaction: revert ${error} -- Reason given: ${error}.`);
      });

      it("Test vesting exist", async () => {
        let amount = BigNumber(7 * 10**18);
        let vesting = await Vesting.new();
        await vesting.setVesting(
            user1, 
            amount, 
            3, 
            5 * 60 * 1000,
            {from: deployer, value: amount}
        );
        let error = 'Vesting exists';
        await vesting.setVesting(
            user1, 
            amount, 
            3, 
            5 * 60 * 1000,
            {from: deployer, value: amount}
        ).should.be.rejectedWith(`Returned error: VM Exception while processing transaction: revert ${error} -- Reason given: ${error}.`);
      });
  });
});






