pragma solidity ^0.5.0;

import "./Utils/SigUtil.sol";
import "./Utils/SafeMath.sol";
import "./Utils/Role.sol";
import "./Utils/AddressManager.sol";
import "./Token/ITokensRecipient.sol";
import "./Token/IToken.sol";
import "./IStakeManager.sol";


contract Btc2eth1 is AddressManager, ITokensRecipient, Role {
    using SafeMath for uint256;

    mapping(bytes32 => bytes32) private orders;
    mapping(bytes32 => address) private wshmap; // sha256 hash
    mapping(bytes32 => uint256) private valids;
    mapping(bytes32 => uint256) private counts;
    mapping(address => uint256) private minted;
    mapping(address => bytes32) private keymap;  

    event UpdatedWsh(address indexed leader, bytes32 wsh, bytes32 ipfsHash, bytes pubkey);
    event Registered(address indexed sender, bytes32 ipfsHash, bytes pubkey);

    IToken private btct;
    IStakeManager private sm;
    uint256 private requireCount;

    constructor (address _btct, address _onboard, uint256 _requireCount) public {
        btct = IToken(_btct);
        sm = IStakeManager(_onboard);
        _setOwner(msg.sender);
        requireCount = _requireCount;
    }

    function register(
        bytes32 _ipfsHash,
        bytes memory _pubkey
    ) public notPaused {
        require(checkUserPubkey(msg.sender, _pubkey), "msg.sender is not match pubkey");
        require(sm.isValidWitnessConsortium(msg.sender), "msg.sender != witness");
        keymap[msg.sender] = _ipfsHash;
        emit Registered(msg.sender, _ipfsHash, _pubkey);
    }

    // witness leader submit _wsh
    function updateWsh(
        bytes32 _wsh, 
        bytes32 _ipfsHash,
        bytes memory _pubkey
    ) public notPaused {
        require(wshmap[_wsh] == address(0x0), "wsh is 0x0");
        wshmap[_wsh] = msg.sender;
        valids[_wsh] = requireCount * 100;
        counts[_wsh] = 0;
        emit UpdatedWsh(msg.sender, _wsh, _ipfsHash, _pubkey);
    }

    // lender htlc -> Witness secret -> go to treasury. Expired -> Bob pubkey -> refund
    // minter htlc -> bob secret -> refund to alice, Expired ->  go to treasury
    // signed by minter
    function attachMint(
        bytes32 _wsh, 
        address _minter, 
        uint256 _satoshis,
        uint256 _period,
        bytes32 _depositTx, 
        bytes memory _sig
    ) public notPaused {
        require(wshmap[_wsh] != address(0x0), "wsh is not 0x0");
        bytes32 orderHash = SigUtil.prefixed(keccak256(abi.encodePacked(
            _wsh,
            _minter,
            _satoshis,
            _period,
            _depositTx
        )));
        require(orders[_wsh] == 0x0, "wsh is already used");
        address signer = SigUtil.recover(orderHash, _sig);
        require(signer == _minter, "signer != _minter");
        orders[_wsh] = orderHash;
    }

    function validFromWitness(
        bytes32 _wsh,
        bool _isValid
    ) public notPaused {
        require(valids[_wsh] > 1);

        if (_isValid) {
            counts[_wsh] = counts[_wsh] + 100;  
        }
        if (counts[_wsh] >= valids[_wsh] * 2/3) {
            valids[_wsh] = 1;
        }
    }

    function execMint(
        bytes32 _wsh, 
        address _minter, 
        uint256 _satoshis,
        uint256 _period,
        bytes32 _depositTx
    ) public notPaused {
        bytes32 orderHash = SigUtil.prefixed(keccak256(abi.encodePacked(
            _wsh,
            _minter,
            _satoshis,
            _period,
            _depositTx
        )));
        require(orders[_wsh] == orderHash);
        require(valids[_wsh] == 1);

        btct.mint(_minter, _satoshis);
        valids[_wsh] = 0;
    }

    function execBurn(
        bytes32 _wsh, 
        address _minter, 
        uint256 _satoshis,
        uint256 _period,
        bytes32 _depositTx
    ) public notPaused {
        bytes32 orderHash = SigUtil.prefixed(keccak256(abi.encodePacked(
            _wsh,
            _minter,
            _satoshis,
            _period,
            _depositTx
        )));
        require(orders[_wsh] == orderHash);
        require(minted[_minter] >= _satoshis);
        minted[_minter] = minted[_minter] - _satoshis;
        if (block.timestamp <= _period + 1 hours) {
            orders[_wsh] == "0x10"; // burned by period
            counts[_wsh] = _period;
        } else {
            orders[_wsh] == "0x20";
        }
    }

    function refund(
        bytes32 _wsh,
        bytes32 _ws
    ) public notPaused {
        require(valids[_wsh] == 0); // 0 => minted
        if (block.timestamp <= counts[_wsh]) {
            if (orders[sha256(abi.encodePacked(_ws))] == "0x10") {
                // reset
                wshmap[_wsh] = address(0x0);
                counts[_wsh] = 0;
            }
        } else {
            require(wshmap[_wsh] != address(0x0));
            if (orders[_wsh] == "0x10") {
                // slash
                //wshmap[_wsh] = "0x40";
            }
        }
    }

    function setPaused(bool _paused) public onlyOwner {
        _setPaused(_paused);
        btct.setPaused(_paused);
    }

    function getKey(address _who) public view returns (bytes32) {
        return keymap[_who];
    }

    //ITokensRecipient callback
    function onTokenReceived(address _token, address _sender, uint256 _amount) public notPaused returns (bool) {
        if (msg.sender != address(btct)) {
            return false;
        }
        if (_token != address(btct)) {
            return false;
        }
        minted[_sender] = minted[_sender].add(_amount);
        return true;
    }

    function deposit(uint256 _amount) public notPaused {
        btct.transferFrom(msg.sender, address(this), _amount);
        minted[msg.sender] = minted[msg.sender].add(_amount);
    }
}
