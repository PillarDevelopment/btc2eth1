pragma solidity ^0.5.0;

import "./Token/Token.sol";
import "./Utils/SigUtil.sol";
import "./Utils/AddressManager.sol";


contract Btc2eth1 is AddressManager {

    /**
     * message format
     * // txHash = SwingbyTx(address _lender)
     */
    mapping(bytes32 => bytes32) private orderState;
    mapping(uint256 => bytes32) private wshs; // sha256 hash
    mapping(uint256 => bytes32) private groups;

    event JoinGroup(address indexed who, uint256 _groupId, bytes pubkey);
    
    Token private token;

    function jonGroup(uint256 _groupId, address[] memory _members, bytes memory _pubkey) public {
        require(AddressManager.checkUserPubkey(msg.sender, _pubkey), "address is not verified");
        bytes32 temp = 0x0;
        for (uint i = 0; i <= _members.length - 1; i++) {
            temp = keccak256(abi.encodePacked(temp, _members[i]));
        }
        require(temp == groups[_groupId], "hash is not matched");
        groups[_groupId] = keccak256(abi.encodePacked(temp, msg.sender));
        emit JoinGroup(msg.sender, _groupId, _pubkey);
    }

    function updateWsh(uint256 _groupId, address[] memory _members, uint256 _index, bytes32 _wsh) public {
        require(wshs[_groupId] == 0x0, "wsh is not 0x0");
        bytes32 temp = 0x0;
        for (uint i = 0; i <= _members.length - 1; i++) {
            if (_index == i) {
                require(msg.sender == _members[i], "msg.sender != members");
            }
            temp = keccak256(abi.encodePacked(temp, _members[i]));
        }
        require(temp == groups[_groupId], "hash is not matched");
        wshs[_groupId] = _wsh;
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

        
        require(orderState[_lsh] == 0x0);
        orderState[_lsh] = keccak256(abi.encodePacked(_wsh, _satohis)); // add secret hash to orderState with satoshis
    }

}