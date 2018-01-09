pragma solidity ^0.4.13;

import "./ERC223Token.sol";

contract X8CToken is ERC223Token {

    function X8CToken() public {    
        name = "X8CToken";
        symbol = "X8C";
        decimals = 18;
    }
}