// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

struct VestingAccount {
    uint vestingStart;
    uint parts;
    uint accuracyInSeconds;
    uint amount;
    uint withdrawn;
}
  
contract Vesting {
    mapping(address => VestingAccount) public accounts;
    address public owner = msg.sender;
    
    modifier onlyOwner() {
        require(
          msg.sender == owner,
          "This function is restricted to the contract's owner"
        );
        _; // сюда будет вставлено само тело функции
    }
  
    function setVesting(address account, uint amount, uint parts, uint accuracyInSeconds) public payable onlyOwner {
        VestingAccount memory memoryAccount = accounts[account];
        require(memoryAccount.withdrawn == memoryAccount.parts, "Vesting exists");
        require(msg.value == amount, "Vesting amount should equal to value");
        require(parts > 0, "Vesting termin should be more then zero");
        require(amount >= parts, "Very small value");
        require(account != 0x0000000000000000000000000000000000000000, "Account should be not 0x0000000000000000000000000000000000000000");
        accounts[account].amount = amount;
        accounts[account].vestingStart = block.timestamp;
        accounts[account].parts = parts;
        accounts[account].accuracyInSeconds = accuracyInSeconds;
        accounts[account].withdrawn = 0;
    }
    
    function claim() public {
        VestingAccount memory account = accounts[msg.sender];
        require(account.vestingStart != 0, "Account Not Found");
        uint amountPart = account.amount / account.parts;
        uint timeDifferent = (block.timestamp - account.vestingStart) / account.accuracyInSeconds;
        require(timeDifferent > account.withdrawn, "Nothing to withdraw");
        uint availableParts = timeDifferent - account.withdrawn;
        uint transferAmount;
        if (availableParts + account.withdrawn == account.parts) {
            transferAmount = account.amount - account.withdrawn * amountPart;
        } else {
            transferAmount = availableParts * amountPart;
        }
        require(transferAmount != 0, "Nothing to withdraw");
        payable(msg.sender).transfer(transferAmount);
        accounts[msg.sender].withdrawn = account.withdrawn + availableParts;
    }
}
