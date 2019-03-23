pragma solidity 0.5.1;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */

/* interface */  
contract IERC20 {
    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);
}

