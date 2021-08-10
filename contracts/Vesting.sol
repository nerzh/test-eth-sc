// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

struct VestingAccount {
    uint vestingStart;
    uint vestingDays;
    uint amount;
    uint withdrawn;
}
  
contract Vesting {
    mapping(address => VestingAccount) public accounts;
    address public owner = msg.sender;
    uint public test1;
    address public test2;
    
    modifier onlyOwner() {
        require(
          msg.sender == owner,
          "This function is restricted to the contract's owner"
        );
        _; // сюда будет вставлено само тело функции
    }
  
    function setVesting(address account, uint amount, uint vestingDays) public payable onlyOwner {
        require(accounts[account].withdrawn == accounts[account].vestingDays, "Vesting exists");
        require(msg.value == amount, "Vesting amount should equal to value");
        require(vestingDays > 0, "Vesting termin should be more then zero");
        require(amount >= vestingDays, "Very small value");
        require(account != 0x0000000000000000000000000000000000000000, "Account should be not 0x0000000000000000000000000000000000000000");
        accounts[account].amount = amount;
        accounts[account].vestingStart = block.timestamp;
        accounts[account].vestingDays = vestingDays;
        accounts[account].withdrawn = 0;
    }
  
    struct Test {
        uint amountPart;
        uint timeDifferent;
        uint availableParts;
        uint transferAmount;
        uint balance;
    } 
    
    Test public test;
    function claim() public {
        // emit UInt(address(this).balance);
        VestingAccount memory account = accounts[msg.sender];
        require(account.vestingStart != 0, "Account Not Found");
        uint amountPart = account.amount / account.vestingDays;
        test.amountPart = amountPart;
        uint timeDifferent = (block.timestamp - account.vestingStart) / 30 seconds;
        test.timeDifferent = timeDifferent;
        require(timeDifferent > account.withdrawn, "Nothing to withdraw");
        uint availableParts = timeDifferent - account.withdrawn;
        test.availableParts = availableParts;
        uint transferAmount;
        if (availableParts + account.withdrawn == account.vestingDays) {
            transferAmount = account.amount - account.withdrawn * amountPart;
        } else {
            transferAmount = availableParts * amountPart;
        }
        test.transferAmount = transferAmount;
        require(transferAmount != 0, "Nothing to withdraw");
        payable(msg.sender).transfer(transferAmount);
        accounts[msg.sender].withdrawn = account.withdrawn + availableParts;
        test.balance = address(this).balance;
        // 7000000000000000000
    }
}
