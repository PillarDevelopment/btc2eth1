pragma solidity 0.5.1;

import "./IERC20.sol";
/**
 * @title IERC20Base interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */

/* interface */  
contract IERC20Base is IERC20 {
    function mint(address _to, uint256 _amount) public returns (bool);        

    function burn(address _to, uint256 _amount) public returns (bool);        

    function setOwner(address _owner) public returns (bool);

    function owner() public view returns (address);

    function setPaused(bool _paused) public returns (bool);

    function isPaused() public view returns (bool);
}

