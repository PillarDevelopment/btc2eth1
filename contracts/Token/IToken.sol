pragma solidity 0.5.0;

/**
 * @title IToken interface
 * @dev 
 */
/* interface */  

contract IToken { 
   
    function transfer(address to, uint256 value) public returns (bool);
    
    function transferMetaTx(
        address _from, 
        address _to,  
        uint256 _amount,  
        uint256[4] memory _inputs, // 0 => _gasPrice, 1 => _gasLimit, 2 => _tokenPrice, 3 => _nonce
        address _relayer,
        uint8   _v, 
        bytes32 _r,
        bytes32 _s,
        address _tokenReceiver
    ) public returns (bool);

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