pragma solidity 0.5.0;

/**
 * @title IToken interface
 * @dev 
 */
/* interface */  

interface IToken { 
   
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function mint(address _to, uint256 _amount) external returns (bool);

    function totalSupply() external view returns (uint256);
    
    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}