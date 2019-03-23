pragma solidity 0.5.1;

/**
 * @title IStakeManager interface
 * @dev 
 */
/* interface */  

contract IStakeManager { 
   
    function isValidWitnessConsortium(address who) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function mint(address _to, uint256 _amount) public returns (bool);

    function totalSupply() public view returns (uint256);
    
    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);

    function name() public view returns (string memory);

    function symbol() public view returns (string memory);

    function decimals() public view returns (uint8);
}