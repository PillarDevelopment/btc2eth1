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

    function setOwner(address _owner) public {
        require(owner == address(0x0));
        owner = _owner;
    }

    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}
