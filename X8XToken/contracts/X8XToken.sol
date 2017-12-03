pragma solidity ^0.4.13;

import "./ERC20Token.sol";
import "./Utils/Lockable.sol";

contract X8XToken is ERC20Token {

    /* Initializes contract */
    function X8XToken() {
        standard = "X8X token v1.0";
        name = "X8XToken";
        symbol = "X8X";
        decimals = 18;
        totalSupplyLimit = 100000000 * 10**18;
        lockFromSelf(4894000, "Lock before crowdsale starts");
    }
}