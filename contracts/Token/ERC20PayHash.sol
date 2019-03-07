pragma solidity 0.5.0;

/**
 * @title ERC20PayHash hash pay using back step hash onions.
 * @dev 
 */

contract ERC20PayHash {    
        
    mapping(address => bytes32) private lastHash;

    bytes32 private stream;
    bytes32 private settled;
    
    event AddSecretHashEvent(address sender, bytes32 latest);
    event AddStreamEvent(bytes32 prevHash, bytes32 txHash, bytes32 lastHash);
    event Transfer(address from, address to, uint256 amount);

    function addLatest(bytes32 _latestHash) public {
        require(lastHash[msg.sender] == 0x0);
        lastHash[msg.sender] = _latestHash;
        emit AddSecretHashEvent(msg.sender, _latestHash);
    }

    // _txHash = keccak256(<from>, <to>, <amount>, <prevHash>, <secret>)
    function addStream(bytes32 _txHash) public {
        bytes32 lastStream = stream;
        // if _txHash is not correct, sender must not reveal secret. payer is safu :) 
        // after settlement, payer can re-submit the correct tx to the relayer
        stream = keccak256(abi.encodePacked(lastStream, _txHash)); 
        emit AddStreamEvent(lastStream, _txHash, stream);
    }

    function getStream() public view returns (bytes32) {
        return stream;
    }

    function getLatest(address _user) public view returns (bytes32) {
        return lastHash[_user];
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
                if (lastHash[_from[i]] == keccak256(abi.encodePacked(_prevHashOrTxhash[i], _secret[i]))) {
                    lastHash[_from[i]] = _prevHashOrTxhash[i]; 
                    //_transfer(_from[i], _to[i], _amount[i]);
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
    
    function _transfer(address _from, address _to, uint256 _amount) internal;

}