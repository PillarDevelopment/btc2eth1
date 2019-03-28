pragma solidity 0.5.1;

/**
 * @title Role 
 * @dev 
 */

contract Role { 
    
    address private _owner;
    bool    private _paused;

    modifier onlyOwner {
        require(_owner == msg.sender);
        _;
    }
    
    modifier notPaused {
        require(!_paused);
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isPaused() public view returns (bool) {
        return _paused;
    }

    function _setOwner(address newOwner) internal {
        _owner = newOwner;
    }

    function _setPaused(bool paused) internal {
        _paused = paused;
    }
}
