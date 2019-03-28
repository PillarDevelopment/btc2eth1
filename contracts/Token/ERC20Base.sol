pragma solidity 0.5.1;

import "./ERC20.sol";
import "../Utils/Role.sol";

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
 * Using OpenZepplein https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/ERC20.sol
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
/**
 * @title ERC20Base
 * @dev ERC20Base logic
 */

contract ERC20Base is ERC20, Role {

    function transfer(address _to, uint256 _value) public notPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public notPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public notPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseAllowance(address _spender, uint _addedValue) public notPaused returns (bool success) {
        return super.increaseAllowance(_spender, _addedValue);
    }

    function decreaseAllowance(address _spender, uint _subtractedValue) public notPaused returns (bool success) {
        return super.decreaseAllowance(_spender, _subtractedValue);
    }

    function mint(address _to, uint256 _amount) public notPaused onlyOwner returns (bool) {        
        _mint(_to, _amount);
        return true;
    }

    function burn(address _to, uint256 _amount) public notPaused onlyOwner returns (bool) {        
        _burn(_to, _amount);
        return true;
    }

    function setOwner(address _owner) public notPaused onlyOwner returns (bool) {
        _setOwner(_owner);
        return true;
    }

    function setPaused(bool _paused) public onlyOwner returns (bool) {
        _setPaused(_paused);
        return true;
    }
}
