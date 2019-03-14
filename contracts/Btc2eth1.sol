pragma solidity ^0.5.0;

import "./Token/Token.sol";
import "./Utils/SigUtil.sol";
import "./Utils/AddressManager.sol";
import "./Token/ITokensRecipient.sol";


contract Btc2eth1 is AddressManager, ITokensRecipient {
    using SafeMath for uint256;

    mapping(bytes32 => bytes32) private orders;
    mapping(uint256 => bytes32) private wshmap; // sha256 hash
    mapping(uint256 => bytes32) private groups;
    mapping(uint256 => uint256) private valids;
    mapping(uint256 => uint256) private counts;
    mapping(address => uint256) private minted;

    event JoinGroup(address indexed who, uint256 _groupId, bytes pubkey);
    
    Token private btct;

    constructor (address _btct) public {
        btct = Token(_btct);
    }

    function jonWitnessGroup(uint256 _groupId, address[] memory _members, bytes memory _pubkey) public {
        require(AddressManager.checkUserPubkey(msg.sender, _pubkey), "address is not verified");
        require(wshmap[_groupId] == 0x0, "wsh is not 0x0");
        bytes32 temp = 0x0;
        for (uint i = 0; i <= _members.length - 1; i++) {
            temp = keccak256(abi.encodePacked(temp, _members[i]));
        }
        require(temp == groups[_groupId], "hash is not matched");
        groups[_groupId] = keccak256(abi.encodePacked(temp, msg.sender));
        emit JoinGroup(msg.sender, _groupId, _pubkey);
    }

    function addWsh(uint256 _groupId, address[] memory _members, uint256 _index, bytes32 _wsh) public {
        require(wshmap[_groupId] == 0x0, "wsh is 0x0");
        require(_members.length >= 3, "members count < 3");
        bytes32 temp = 0x0;
        for (uint i = 0; i <= _members.length - 1; i++) {
            if (_index == i) {
                require(msg.sender == _members[i], "msg.sender != members");
            }
            temp = keccak256(abi.encodePacked(temp, _members[i]));
        }
        require(temp == groups[_groupId], "hash is not matched");
        wshmap[_groupId] = _wsh;
        valids[_groupId] = _members.length * 100;
        counts[_groupId] = 0;
    }

    // lender htlc -> Witness secret -> go to treasury. Expired -> Bob pubkey -> refund
    // minter htlc -> bob secret 
    // signed by minter
    function attachMint(
        uint256 _groupId, 
        address _minter, 
        uint256 _satoshis,
        uint256 _period,
        bytes32 _depositTx, 
        bytes memory _sig
    ) public {
        require(wshmap[_groupId] != 0x0, "wsh is not 0x0");
        bytes32 orderHash = SigUtil.prefixed(keccak256(abi.encodePacked(
            _groupId,
            _minter,
            _satoshis,
            _period,
            _depositTx
        )));
        require(orders[wshmap[_groupId]] == 0x0, "wsh is already used");
        address signer = SigUtil.recover(orderHash, _sig);
        require(signer == _minter, "signer != _minter");
        orders[wshmap[_groupId]] = orderHash;
    }

    function validFromWitness(
        uint256 _groupId,
        address[] memory _members, 
        uint256 _index,
        bool _isValid
    ) public {
        require(valids[_groupId] > 1);
        bytes32 temp = 0x0;
        for (uint i = 0; i <= _members.length - 1; i++) {
            if (_index == i) {
                require(msg.sender == _members[i], "msg.sender != members");
            }
            temp = keccak256(abi.encodePacked(temp, _members[i]));
        }
        require(temp == groups[_groupId], "hash is not matched");
        if (_isValid) {
            counts[_groupId] = counts[_groupId] + 100;  
        }
        if (counts[_groupId] >= valids[_groupId] * 2/3) {
            valids[_groupId] = 1;
        }
    }

    function execMint(
        uint256 _groupId, 
        address _minter, 
        uint256 _satoshis,
        uint256 _period,
        bytes32 _depositTx
    ) public {
        bytes32 orderHash = SigUtil.prefixed(keccak256(abi.encodePacked(
            _groupId,
            _minter,
            _satoshis,
            _period,
            _depositTx
        )));
        require(orders[wshmap[_groupId]] == orderHash);
        require(valids[_groupId] == 1);

        btct.mint(_minter, _satoshis);
        valids[_groupId] = 0;
    }

    function execBurn(
        uint256 _groupId, 
        address _minter, 
        uint256 _satoshis,
        uint256 _period,
        bytes32 _depositTx
    ) public {
        bytes32 orderHash = SigUtil.prefixed(keccak256(abi.encodePacked(
            _groupId,
            _minter,
            _satoshis,
            _period,
            _depositTx
        )));
        require(orders[wshmap[_groupId]] == orderHash);
        require(minted[_minter] >= _satoshis);
        minted[_minter] = minted[_minter] - _satoshis;
        if (block.timestamp <= _period + 1 hours) {
            orders[wshmap[_groupId]] == "0x10"; // burned by period
            counts[_groupId] = _period;
        } else {
            orders[wshmap[_groupId]] == "0x20";
        }
    }

    function refund(
        uint256 _groupId,
        bytes32 _ws
    ) public {
        require(valids[_groupId] == 0); // 0 => minted
        if (block.timestamp <= counts[_groupId]) {
            if (orders[sha256(abi.encodePacked(_ws))] == "0x10") {
                // reset
                wshmap[_groupId] = 0x0;
                counts[_groupId] = 0;
            }
        } else {
            require(wshmap[_groupId] != 0x0);
            if (orders[wshmap[_groupId]] == "0x10") {
                // slash
                wshmap[_groupId] = "0x40";
            }
        }
    }

    //ITokensRecipient callback
    function onTokenReceived(address _token, address _sender, uint256 _amount) public returns (bool) {
        if (msg.sender != address(btct)) {
            return false;
        }
        if (_token != address(btct)) {
            return false;
        }
        minted[_sender] = minted[_sender].add(_amount);
        return true;
    }

    function deposit(uint256 _amount) public {
        btct.transferFrom(msg.sender, address(this), _amount);
        minted[msg.sender] = minted[msg.sender].add(_amount);
    }
}
