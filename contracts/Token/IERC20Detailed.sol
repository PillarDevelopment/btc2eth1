pragma solidity 0.5.0;

import "./IERC20.sol";

/**
 * @title IERC20Detailed interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
/* interface */  

contract IERC20Detailed is IERC20 { 
    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function decimals() public view returns (uint8);
}