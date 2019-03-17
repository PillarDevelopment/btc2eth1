pragma solidity 0.5.0;

/**
 * @title Role 
 * @dev 
 */

contract Role { 
    
    address private owner;
    bool    private paused;

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    modifier notPaused {
        require(!paused);
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function _setOwner(address _owner) internal {
        owner = _owner;
    }

    function _setPaused(bool _paused) internal {
        paused = _paused;
    }
}
