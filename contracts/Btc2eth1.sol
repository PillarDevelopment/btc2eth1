pragma solidity ^0.5.0;

import "./Token/Token.sol";
import "./Utils/SigUtil.sol";


contract Btc2eth1 {

    /**
     * message format
     * // txHash = SwingbyTx(address _lender)
     */
    mapping(uint256 => bytes32) private witnessState;
    mapping(bytes32 => bytes32) private orderState;
    mapping(uint256 => bytes32) private wshs; // sha256 hash
    
    Token private token;

    modifier isValidStakes(uint256 _amount) {
        // token isLocked
        //require(gov.isLocked(_amount, msg.sender));
        _;
    }
    
    modifier onlyWitness() {
    //    require(gov.isWtiness(msg.sender));
        _;
    }

    constructor(address _token) public {
        token = Token(_token);
    }
    
    // join witness yourself
    function joinWitness(uint256 _id, address[] memory _members) public isValidStakes(20000) {
        bytes32 temp;
        for (uint i = 1; i < _members.length; i++) {
            temp = keccak256(abi.encodePacked(temp, _members[i]));
        }
        require(temp == witnessState[_id]);
        witnessState[_id] = keccak256(abi.encodePacked(temp, msg.sender));
    }
    
    // update secret w cycles
    function updateWsh(uint256 _id, address[] memory _members, uint256 index, bytes memory _oldWs, bytes32 _newWsh) public {
        bytes32 temp;
        for (uint i = 0; i < _members.length-1; i++) {
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
    function matchOrder(
        address _lender,
        address _minter, 
        uint256 _satohis, 
        bytes32 _wsh, 
        bytes32 _lsh, 
        bytes32 _msh,
        bytes32 _lenderTxId,
        bytes32 _minterTxId,
        bytes memory _lenderSig,
        bytes memory _minterSig
    ) public {
        bytes32 lenderTx = SigUtil.prefixed(keccak256(abi.encodePacked(
            _lender, 
            _satohis, 
            _wsh, 
            _lsh,
            _lenderTxId
        )));
        address lender = SigUtil.recover(lenderTx, _lenderSig);
        require(lender == _lender, "lender != _lender");

        bytes32 minterTx = SigUtil.prefixed(keccak256(abi.encodePacked(
            lenderTx,
            _msh,
            _minterTxId
        )));
        address minter = SigUtil.recover(minterTx, _minterSig);
        require(minter == _minter, "minter != _minter");

        
        require(_lender == SigUtil.recover(_hash, _sig));
        require(orderState[_lsh] == 0x0);
        orderState[_lsh] = keccak256(abi.encodePacked(_wsh, _satohis)); // add secret hash to orderState with satoshis
    }
    
    // if ws and ls reveal send btc => tresury. 
    function lenderCut(bytes memory _ls, bytes memory _ws, uint256 _satohis) public {
       
        //require(orderState[sha256(_ls)] == keccak256(abi.encodePacked(sha256(_ws), _satohis)));
        //orderState[sha256(_ls)] = bytes32('isUsedXXXX');
        //slash(lender);
        
    }
    
    // if ls and ms reveal sen btc -> tresury
    
    
}