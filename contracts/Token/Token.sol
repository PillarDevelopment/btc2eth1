pragma solidity 0.5.0;

import "./ERC20MetaTx.sol";
import "./ERC20Base.sol";

/**
 * @title Token token
 * @dev 
 */

contract Token is ERC20MetaTx, ERC20Base { 

    string private _name;
    string private _symbol;
    uint8  private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 _value) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        setOwner(msg.sender);
        _mint(msg.sender, _value);
    }

    // override
    function transferMetaTx(
        address _from, 
        address _to,  
        uint256 _amount, 
        uint256 _nonce,
        uint256[3] memory _inputs, // 0 => _gasPrice, 1 => _gasLimit, 2 => _gasTokenPerWei,
        address _relayer,
        address _tokenReceiver,
        bytes memory _sig
    ) public notPaused returns (bool) {
        return super.transferMetaTx(_from, _to, _amount, _nonce, _inputs, _relayer, _tokenReceiver, _sig);
    }
    
    /**
     * @return the name of the token.
     */
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