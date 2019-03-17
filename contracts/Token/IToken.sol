pragma solidity 0.5.0;

/**
 * @title IToken interface
 * @dev 
 */
/* interface */  

contract IToken { 
   
    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function mint(address _to, uint256 _amount) public returns (bool);

    function setPaused(bool _paused) public returns (bool);

    function setOwner(address _owner) public returns (bool);

    function totalSupply() public view returns (uint256);
    
    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);

    function name() public view returns (string memory);

    function symbol() public view returns (string memory);

    function decimals() public view returns (uint8);
}