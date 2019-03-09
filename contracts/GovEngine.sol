pragma solidity 0.5.0;

import "./Token/IToken.sol";
import "./Token/ITokensRecipient.sol";
import "./Utils/SafeMath.sol";


contract GovEngine is ITokensRecipient {
    using SafeMath for uint256;

    mapping(address => uint256) private stakes; 

    IToken private gov;
    
    constructor(address _gov) public {
        gov = IToken(_gov);
    }

    function depositToken(uint256 _amount) public {
        gov.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] = stakes[msg.sender].add(_amount);
    }

    function onTokenReceived(address _token, address _sender, uint256 _amount) public {
        require(msg.sender == address(gov));
        require(_token == address(gov));
        stakes[_sender] = stakes[_sender].add(_amount);
    }

    function transferOut() public {
        uint256 amount = stakes[msg.sender];
        stakes[msg.sender] = stakes[msg.sender].sub(amount);
    }



    

    
    
    
}