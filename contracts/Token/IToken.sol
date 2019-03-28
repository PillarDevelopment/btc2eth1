pragma solidity 0.5.1;

import "./IERC20MetaTx.sol";
import "./IERC20Base.sol";

/**
 * @title IToken interface
 * @dev 
 */
/* interface */  

contract IToken is IERC20MetaTx, IERC20Base { 

    function name() public view returns (string memory);

    function symbol() public view returns (string memory);

    function decimals() public view returns (uint8);
}