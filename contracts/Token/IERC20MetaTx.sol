pragma solidity 0.5.1;

/**
 * @title IToken interface
 * @dev 
 */
/* interface */  

contract IERC20MetaTx { 

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

    function getTransactionHash(
        address _from, 
        address _to,  
        uint256 _amount, 
        uint256[4] memory _inputs, // 0 => _gasPrice, 1 => _gasLimit, 2 => _tokenPrice, 3 => _nonce
        address _relayer
    ) public pure returns (bytes32);

    function setEstimateTokenPrice(uint256 _tokenPrice) public returns (bool);

    function getEstimateTokenPrice(uint256 _tokenPrice) public returns (uint256);

    function maxFees(uint256 _gasPrice, uint256 _tokenPrice) public view returns (uint256);

    function getNonce(address _from) public view returns (uint256);
}