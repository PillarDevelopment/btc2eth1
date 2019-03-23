pragma solidity 0.5.1;

import "./IERC20.sol";

/**
 * @title IToken interface
 * @dev 
 */
/* interface */  

contract IToken is IERC20 { 
   
    function mint(address _to, uint256 _amount) public returns (bool);

    function setOwner(address _owner) public returns (bool);

    function setPaused(bool _paused) public returns (bool);

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

    function setEstimateTokenPrice(uint256 _tokenPrice) public returns (bool);

    function getEstimateTokenPrice(uint256 _tokenPrice) public returns (uint256);

    function name() public view returns (string memory);

    function symbol() public view returns (string memory);

    function decimals() public view returns (uint8);
}