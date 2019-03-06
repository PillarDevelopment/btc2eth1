pragma solidity 0.5.0;

import "./ERC20Detailed.sol";

/**
 * @title ERC20HashPay hash pay using back step hash onions.
 * @dev 
 */

contract ERC20HashPay is ERC20Detailed {    
        
    mapping(address => bytes32) private lastHash;

    bytes32 private stream;
    bytes32 private settled;

    address public relayer;
        
    event AddStreamEvent(bytes32 prevHash, bytes32 txHash, bytes32 lastHash);
    event Transfer(address from, address to, uint256 amount);

    constructor (string memory name, string memory symbol, uint8 decimals) public 
        ERC20Detailed(name, symbol, decimals) {
        relayer = msg.sender;
    }

    function addLatest(bytes32 _latestHash) public {
        lastHash[msg.sender] = _latestHash;
    }

    // _txHash = keccak256(<from>, <to>, <amount>, <prevHash>, <secret>)
    function addStream(bytes32 _txHash) public {
        bytes32 lastStream = stream;
        // if _txHash is not correct, sender must not reveal secret. payer is safu :) 
        // after settlement, payer can re-submit the correct tx to the relayer
        stream = keccak256(abi.encodePacked(lastStream, _txHash)); 
        emit AddStreamEvent(lastStream, _txHash, stream);
    }

    function settle(
        address[] memory _from, 
        address[] memory _to, 
        uint256[] memory _amount, 
        bytes32[] memory _prevHashOrTxhash, 
        bytes32[] memory _secret
    ) public returns (bool) {
        bytes32 lastSettled = settled;
        for (uint256 i=0; i <= _from.length - 1; i++) {
            if (_secret[i] == 0x0) {
                lastSettled = keccak256(abi.encodePacked(lastSettled, _prevHashOrTxhash[i]));
            } else {
                bytes32 txHash = keccak256(abi.encodePacked(
                    _from[i], 
                    _to[i], 
                    _amount[i], 
                    _prevHashOrTxhash[i], 
                    _secret[i]
                ));
                // create stream onions.
                lastSettled = keccak256(abi.encodePacked(lastSettled, txHash));
                // if txHash is correct, _prevHashOrTxhash is available to pay net payment.
                // to protect re pay attack, lastHash will update in this cycles.
                if (lastHash[msg.sender] == keccak256(abi.encodePacked(_prevHashOrTxhash[i], _secret[i]))) {
                    lastHash[msg.sender] = _prevHashOrTxhash[i]; 
                    _transfer(_from[i], _to[i], _amount[i]);
                    emit Transfer(_from[i], _to[i], _amount[i]);
                }
            }
        }
        if (stream != lastSettled) {
            revert();
        }
        settled = lastSettled;
        return true;
    }
    
    function getHash(
        address _from, 
        address _to, 
        uint256 _amount,
        bytes32 _prev, 
        bytes32 _secret
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_from, _to, _amount, _prev, _secret));
    }
    
    function getHash(bytes32 _prev, bytes32 _secret) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_prev, _secret));
    }
}