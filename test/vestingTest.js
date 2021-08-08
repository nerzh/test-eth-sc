const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545');
const { expect } = require('chai');
const BigNumber = require('bignumber.js');
const {constants} = require('openzeppelin-test-helpers');
const { ethers } = require("ethers");
const truffleAssert = require('truffle-assertions');

/*eslint-disable no-undef*/
const Vesting = artifacts.require('Vesting');

BigNumber.config({ EXPONENTIAL_AT: 1e+9 });