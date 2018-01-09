pragma solidity ^0.4.13;

contract ERC223TokenInterface {

  string public name;
  string public symbol;
  uint8 public decimals;

  function totalSupply() public constant returns (uint);
  function balanceOf(address who) public constant returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  function transfer(address to, uint value, bytes data, string customFallback) public returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);
}