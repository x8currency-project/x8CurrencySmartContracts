pragma solidity ^0.4.13;

import "./ERC223Token.sol";

contract x8cToken is ERC223Token {

    function x8cToken() public {    
        name = "x8cToken";
        symbol = "x8c";
        decimals = 18;
    }
}