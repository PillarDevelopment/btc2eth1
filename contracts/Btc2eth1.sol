pragma solidity ^0.5.0;


contract Btc2eth1 {

    mapping(uint256 => bytes32) witnessState;
    mapping(bytes32 => uint256) orderState;
    mapping(bytes32 => bytes32) matchState;
    mapping(uint256 => bytes32) wshs; // sha256 hash
    
    modifier isValidStakes(uint256 _amount) {
        // token isLocked
        require(token.isLocked(_amount, msg.sender));
        _;
    }
    
    modifier onlyWitness() {
        require(gov.isWtiness(msg.sender));
        _;
    }
    
    // join witness yourself
    function joinWitness(uint256 _id, address[] memory _members) public isValidStakes(20000) {
        bytes32 temp;
        for(uint i = 1; i< _members.length; i++) {
            temp = keccak256(abi.encodePacked(temp, _members[i]));
        }
        require(temp == witnessState[_id]);
        witnessState[_id] = keccak256(abi.encodePacked(temp, msg.sender));
    }
    
    // update secret w cycles
    function updateWsh(uint256 _id, address[] memory _members, uint256 index, bytes memory _oldWs, bytes32 _newWsh) public {
        bytes32 temp;
        for(uint i = 0; i< _members.length-1; i++) {
            temp = keccak256(abi.encodePacked(temp, _members[i]));
            if (i == index) {
                require(msg.sender == _members[i]);
            }
        }
        require(temp == witnessState[_id]);
        if (wshs[_id] == 0x0) {
            wshs[_id] = _newWsh;
        } else {
            require(wshs[_id] == sha256(_oldWs));
            wshs[_id] = _newWsh;
        }
    }
    
    // not broadcasting deposit tx.
    function submitOrder(address _lender, uint256 _satohis, bytes32 _wsh, bytes32 _lsh, bytes32 _hash, bytes memory _sig) public {
        require(_hash == keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _lender, _satohis, _wsh, _lsh)));
        require(_lender == recover(_hash, _sig));
        require(orderState[_lsh] == 0x0);
        orderState[_lsh] = keccak256(abi.encodePacked(_wsh, _satohis)); // add secret hash to orderState with satoshis
    }
    
    // broadcasting deposittx
    function takeOrder(bytes32 _lsh, bytes32 _wsh, address _minter, uint256 _satohis, bytes32 _msh, bytes32 _hash, bytes memory _sig) public {
        require(_hash == keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _lsh, _minter, _satohis, _msh)));
        require(_minter == recover(_hash, _sig));
        require(matchState[_lsh] == 0x0);
        require(orderState[_lsh] == keccak256(abi.encodePacked(_wsh, _satohis)));
        matchState[_lsh] = _msh;
    }
    // if ws and ls reveal send btc => tresury. 
    function lenderCut(bytes memory _ls, bytes memory _ws, uint256 _satohis) public {
       
        require(orderState[sha256(_ls)] == keccak256(abi.encodePacked(sha256(_ws), _satohis)));
        orderState[sha256(_ls)] = bytes32('isUsedXXXX');
        slash(lender);
        
    }
    
    // if ls and ms reveal sen btc -> tresury
    
    

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    
    function adds(uint64 _amount1, uint64 _amount2) public {
        balances[msg.sender][address(this)] = data({b1: _amount1 + _amount1,
        b2: _amount2 + _amount2,
        b3: _amount2 + _amount2,
        b4: _amount2 + _amount2

        });
    }
    
    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {
        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }


    
    function toBytes(uint256 x) internal pure returns (bytes memory b ) {
        b = new bytes(32);
    // solium-disable-next-line security/no-inline-assembly
        assembly { mstore(add(b, 32), x) 
        }
    }

    
    
    
}