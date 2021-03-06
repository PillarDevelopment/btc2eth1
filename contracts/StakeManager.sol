pragma solidity 0.5.1;

import "./Token/IToken.sol";
import "./Token/ITokensRecipient.sol";
import "./Utils/SafeMath.sol";


contract StakeManager is ITokensRecipient {
    using SafeMath for uint256;

    mapping(address => uint256) private stakes; 
    mapping(address => bool)    private locked;

    address[] private voted;

    mapping(address => bool) private lenderConsortium;
    mapping(address => bool) private witnessConsortium;
    
    bytes32 private proposal; // only support single proposal style
    uint256 private period;
    uint256 private score;
    uint256 private minStakeBalance;
    uint256 private proposalCost;
    uint256 private reserve;

    IToken private gov;


    event SubmittedProposal(bool addOrSub, bool wOrl, address who, uint256 period);
    event Voted(address sender, bool vote, uint256 total);

    constructor(address _gov) public {
        gov = IToken(_gov);
        minStakeBalance = 40000 * 10 ** uint256(gov.decimals());
        proposalCost = 2000 * 10 ** uint256(gov.decimals());
    }

    function () external payable {
        revert(); 
    }   

    //ITokensRecipient callback
    function onTokenReceived(address _sender, uint256 _amount) public returns (bool) {
        if (msg.sender != address(gov)) {
            return false;
        }
        stakes[_sender] = stakes[_sender].add(_amount);
        return true;
    }

    function deposit(uint256 _amount) public returns (bool) {
        gov.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = stakes[msg.sender].add(_amount);
        return true;
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
    function submitProposal(bool _addOrSub, bool _wOrl, address _who, uint256 _period) public returns (bool) {
        require(proposal == 0x0, "proposal is submitted");
        require(isValidStakes(msg.sender, minStakeBalance));
        require(isValidStakes(_who, minStakeBalance));
        require(_period >= block.timestamp + 7 days, "_period < block.timestamp + 7 days");
        require(_period <= block.timestamp + 14 days, "_period >= block.timestamp + 14 days");
        require(isFree(msg.sender));
        require(isFree(_who));
        stakes[msg.sender] = stakes[msg.sender].sub(proposalCost);
        reserve = reserve.add(proposalCost);
        proposal = keccak256(abi.encodePacked(_addOrSub, _wOrl, _who, _period, msg.sender));
        doLock(msg.sender);
        doLock(_who);
        score = gov.totalSupply(); // init vote score min totalsuppy of tokens.
        period = _period;
        emit SubmittedProposal(_addOrSub, _wOrl, _who, _period);
        return true;
    }

    function vote(bool _vote) public returns (bool) {
        require(proposal != 0x0, "proposal is not saved");
        require(isValidStakes(msg.sender, minStakeBalance), "voter insfuffient balances");
        require(!isVoted(msg.sender), "msg.sender already submitted");
        if (_vote) {
            score = score.add(stakes[msg.sender]);
        } else {
            score = score.sub(stakes[msg.sender]);
        }
        voted.push(msg.sender);
        if (reserve >= proposalCost.div(10)) {
            stakes[msg.sender] = stakes[msg.sender].add(proposalCost.div(10)); // add reward 1/10 of proposal cost;
            reserve = reserve.sub(proposalCost.div(10));
        }
        emit Voted(msg.sender, _vote, score);
        return true;
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
        require(block.timestamp >= _period);
        bool success;        
        // vote success
        if (score > gov.totalSupply()) { // agreed
            if (_joinOrLeft) {
                if (_wOrl) {
                    witnessConsortium[_who] = true;
                } else {
                    lenderConsortium[_who] = true;                   
                }
            } else {
                if (_wOrl) {
                    witnessConsortium[_who] = false;
                    doUnlock(_who);
                } else {
                    lenderConsortium[_who] = false;              
                    doUnlock(_who);             
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
        return lenderConsortium[_who];
    }

    function isValidWitnessConsortium(address _who) public view returns (bool) {
        return witnessConsortium[_who];
    }
    
    function getGov() public view returns (address) {
        return address(gov);
    }

    function getStake(address _who) public view returns (uint256) {
        return stakes[_who];
    }

    function getScore() public view returns (uint256) {
        return score;
    }

    function getPeriod() public view returns (uint256) {
        return period;
    }

    function isVoted(address _who) internal view returns (bool) {
        bool result = false;
        if (voted.length == 0) {
            return result;
        }
        for (uint i = 0; i < voted.length - 1; i++) {
            if (voted[i] == _who) {
                result = true;
            }
        }
        return result;
    }

    function isFree(address _who) internal view returns (bool) {
        return !locked[_who];
    }

    function doLock(address _who) internal {
        locked[_who] = true;
    }

    function doUnlock(address _who) internal {
        locked[_who] = false;
    }

    function isValidStakes(address _who, uint256 _stake) internal view returns (bool) {
        if (stakes[_who].sub(_stake) >= 0) {
            return true;
        }
        return false;
    }
}