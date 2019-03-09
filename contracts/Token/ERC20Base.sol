pragma solidity 0.5.0;

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

    function transfer(address to, uint256 value) public notPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public notPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public notPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public notPaused returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public notPaused returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    function mint(address _to, uint256 _amount) public notPaused onlyOwner returns (bool) {        
        _mint(_to, _amount);
        return true;
    }
}
