pragma solidity ^0.4.13;

import "./Interfaces/ERC223RecieverInterface.sol";
import "./Interfaces/ERC223TokenInterface.sol";
import "./Interfaces/ERC20TokenInterface.sol";
import "./Interfaces/tokenRecipientInterface.sol";
import "./Utils/SafeMath.sol";
import "./Utils/Owned.sol";
import "./Utils/Lockable.sol";
 
contract ERC223Token is ERC223TokenInterface, SafeMath, Owned, Lockable {

    mapping(address => uint) balances;
    mapping (address => mapping (address => uint256)) allowances;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 supply;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Mint(address indexed to, uint value);
    event Burn(address indexed from, uint value);

    //
    // Getters
    // 

    function totalSupply() public constant returns (uint256 _totalSupply) {
        return supply;
    } 
  
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    //
    // ERC223 
    //

    function transfer(address _to, uint _value, bytes _data) lockAffected public returns (bool success) {
        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    function transfer(address _to, uint _value, bytes _data, string _customFallback) lockAffected public returns (bool success) {
        if (isContract(_to)) {
            require(balanceOf(msg.sender) >= _value);
            balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
            balances[_to] = safeAdd(balanceOf(_to), _value);
            ERC223RecieverInterface receiver = ERC223RecieverInterface(_to);
            receiver.call.value(0)(bytes4(sha3(_customFallback)), msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }

    function isContract(address _addr) private returns (bool) {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length>0);
    }

    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        ERC223RecieverInterface receiver = ERC223RecieverInterface(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    //
    // ERC20 methods
    //

    function transfer(address _to, uint _value) lockAffected public returns (bool success) {
        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }else {
            return transferToAddress(_to, _value, empty);
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) lockAffected public returns (bool success) {
        bytes memory empty;
        balances[_from] = safeSub(balanceOf(_from), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        allowances[_from][msg.sender] = safeSub(allowance(_from, msg.sender), _value);
        Transfer(_from, _to, _value);
        if (isContract(_to)) {
            ERC223RecieverInterface receiver = ERC223RecieverInterface(_to);
            receiver.tokenFallback(_from, _value, empty);
        }
        return true;
    }

    function approve(address _spender, uint256 _value) lockAffected public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) lockAffected public returns (bool success) {
        tokenRecipientInterface spender = tokenRecipientInterface(_spender);
        approve(_spender, _value);
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    //
    // Other
    //

    function mint(address _to, uint _amount) onlyOwner public {
        balances[_to] = safeAdd(balanceOf(_to), _amount);
        supply = safeAdd(supply, _amount);
        Mint(_to, _amount);
    }

    function burn(uint _amount) public {
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _amount);
        supply = safeSub(supply, _amount);
        Burn(msg.sender, _amount);
    }

    function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) public onlyOwner {
        ERC20TokenInterface(_tokenAddress).transfer(_to, _amount);
    }

}