pragma solidity 0.5.0;

import "./ERC20.sol";

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

contract ERC20Base is ERC20 {

    address private owner;
    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */

    function mint(address _to, uint256 _amount) public returns (bool) {
        if (owner == address(0x0)) {
            owner = msg.sender;
        } 
        require(msg.sender == owner);
        
        _mint(_to, _amount);
        return true;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}
