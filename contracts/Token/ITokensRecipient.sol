pragma solidity 0.5.1;

/**
 * @title TokensRecipient interface
 * @dev see 

/* interface */  

contract ITokensRecipient {
    function onTokenReceived(address _sender, uint256 _amount) public returns (bool);
}

