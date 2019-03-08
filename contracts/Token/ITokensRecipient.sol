pragma solidity 0.5.0;

/**
 * @title TokensRecipient interface
 * @dev see 

/* interface */  

interface ITokensRecipient {
    function onTokenReceived(address _token, address _sender, uint256 _amount) external returns (bool);
}

