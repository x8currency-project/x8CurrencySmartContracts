pragma solidity ^0.4.13;

contract ERC223RecieverInterface {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}