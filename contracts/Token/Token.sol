pragma solidity 0.5.0;

import "./ERC20SimpleMetaTx.sol";
import "./ERC20Base.sol";

/**
 * @title Token token
 * @dev 
 */

contract Token is ERC20SimpleMetaTx, ERC20Base { 

    string private _name;
    string private _symbol;
    uint8  private _decimals;

    function init(string memory name, string memory symbol, uint8 decimals) public {
        require(_decimals == 0x0);
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _mint(msg.sender, 14000);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}