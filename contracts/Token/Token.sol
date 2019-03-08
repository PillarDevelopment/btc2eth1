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

    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        setOwner(msg.sender);
        _mint(msg.sender, 14000);

    }

    function transferMetaTx(
        address _from, 
        address _to,  
        uint256 _amount, 
        uint256 _nonce,
        bool    _isContract,
        bytes memory _sig
    ) public notPaused returns (bool) {
        return super.transferMetaTx(_from, _to, _amount, _nonce, _isContract, _sig);
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