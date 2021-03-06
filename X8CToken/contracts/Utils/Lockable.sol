pragma solidity ^0.4.13;

import "../Utils/Owned.sol";

contract Lockable is Owned {

  uint256 public lockedUntilBlock;

  event ContractLocked(uint256 _untilBlock, string _reason);

  modifier lockAffected {
      require(block.number > lockedUntilBlock);
      _;
  }

  function lockUntil(uint256 _untilBlock, string _reason) onlyOwner public {
    lockedUntilBlock = _untilBlock;
    ContractLocked(_untilBlock, _reason);
  }
}
