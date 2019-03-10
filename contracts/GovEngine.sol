pragma solidity 0.5.0;

import "./Token/IToken.sol";
import "./Token/ITokensRecipient.sol";
import "./Utils/SafeMath.sol";


contract GovEngine is ITokensRecipient {
    using SafeMath for uint256;

    mapping(address => uint256) private stakes; 
    mapping(address => bool) private locked;
    address[] private voted;

    mapping(address => bool) private lenderConsortium;
    mapping(address => bool) private witnessConsortium;
    
    bytes32 private proposal; // only support single proposal style
    uint256 private period;
    uint256 private score;
    uint256 private duration;
    uint256 private minStakeBalance = 40000;
    uint256 private threshold;

    IToken private gov;

    constructor(address _gov) public {
        gov = IToken(_gov);
        threshold = gov.totalSupply();
    }

    //ITokensRecipient callback
    function onTokenReceived(address _token, address _sender, uint256 _amount) public returns (bool) {
        if (msg.sender != address(gov)) {
            return false;
        }
        if (_token != address(gov)) {
            return false;
        }
        stakes[_sender] = stakes[_sender].add(_amount);
        return true;
    }

    function depositToken(uint256 _amount) public {
        gov.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = stakes[msg.sender].add(_amount);
    }

    function transferOut(uint256 _amount) public {
        // when proposal is open, cannot withdraw.
        require(!isVoted(msg.sender));
        // already resign 
        require(isFree(msg.sender));
        stakes[msg.sender] = stakes[msg.sender].sub(_amount);
        gov.transfer(msg.sender, _amount);
    }

    // add or sub members to witness / lender
    // 0 => draft, 1 => finalize, 2 => reject
    function submitProposal(bool _addOrSub, bool _wOrl, address _who, uint256 _period) public returns (bool) {
        require(proposal == 0x0, "proposal is submitted");
        require(isValidStakes(msg.sender, minStakeBalance));
        require(isFree(msg.sender));
        proposal = keccak256(abi.encodePacked(_addOrSub, _wOrl, _who, _period, msg.sender));

        doLock(msg.sender);
        score = threshold; // init vote score min totalsuppy of tokens.
        period = _period;
    }

    function vote(bool _vote) public {
        require(proposal != 0x0, "proposal is not 0x0");
        require(isValidStakes(msg.sender, minStakeBalance), "voter insfuffient balances");
        require(!isVoted(msg.sender), "msg.sender already submitted");
        if (_vote) {
            score.add(stakes[msg.sender]);
        } else {
            score.sub(stakes[msg.sender]);
        }
        voted.push(msg.sender);
    }

    function finalize(
        bool _joinOrLeft, 
        bool _wOrl, 
        address _who, 
        uint256 _period, 
        address _submitter
    ) public returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(_joinOrLeft, _wOrl, _who, _period, _submitter));
        require(hash == proposal, "proposal hash is not correct");
        if (period <= block.timestamp) {
            return false;
        }
        // vote success
        bool success;
        if (score > threshold) { // agreed
            if (_wOrl) {
                if (_joinOrLeft) {
                    require(joinWitnessConsotium(_who));
                } else {
                    require(leftWitnessConsotium(_who));
                }
            } else {
                if (_joinOrLeft) {
                    require(joinLenderConsotium(_who));
                } else {
                    require(leftLenderConsotium(_who));
                }
            }
            success = true;
        } else {
            success = false;
        }
        delete voted;
        proposal = 0x0; // reset proposal
        score = 0;
        doUnlock(_submitter);
        return success;
    }

    function isValidLenderConsortium(address _who) public view returns (bool) {
        if (isValidStakes(_who, 500000)) {
            if (lenderConsortium[_who]) {
                return true;
            }
            return false;
        }
        return false;
    }

    function isVoted(address _who) internal view returns (bool) {
        for (uint i = 0; i < voted.length - 1; i++) {
            if (voted[i] == _who) {
                return true;
            }
        }
        return false;
    }

    function isFree(address _who) internal view returns (bool) {
        if (locked[_who]) {
            return true;
        }
        return false;
    }

    function doLock(address _who) internal {
        locked[_who] = true;
    }

    function doUnlock(address _who) internal {
        locked[_who] = false;
    }

    function joinLenderConsotium(address _who) internal returns (bool) {
        if (isValidStakes(_who, minStakeBalance)) {
            doLock(_who);
            lenderConsortium[_who] = true;
        }
        return false;
    }

    function leftLenderConsotium(address _who) internal returns (bool) {
        if (isValidStakes(_who, minStakeBalance)) {
            doUnlock(_who);
            lenderConsortium[_who] = false;
        }
        return false;
    }

    function joinWitnessConsotium(address _who) internal returns (bool) {
        if (isValidStakes(_who, minStakeBalance)) {
            doLock(_who);
            witnessConsortium[_who] = true;
        }
        return false;
    }

    function leftWitnessConsotium(address _who) internal returns (bool) {
        if (isValidStakes(_who, minStakeBalance)) {
            doUnlock(_who);
            witnessConsortium[_who] = false;
        }
        return false;
    }

    function isValidStakes(address _who, uint256 _stake) internal view returns (bool) {
        if (stakes[_who].sub(_stake) >= 0) {
            return true;
        }
        return false;
    }
}