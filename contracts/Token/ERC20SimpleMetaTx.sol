pragma solidity 0.5.0;

import "../Utils/SigUtil.sol";
import "../Utils/Constant.sol";
import "../Utils/SafeMath.sol";
import "./ITokensRecipient.sol";

/**
 * @title ERC20SimpleMetaTx
 * @dev 
 */

contract ERC20SimpleMetaTx is Constant {
    using SafeMath for uint256;

    mapping(address => uint) private nonces;
    
    function transferSimpleMetaTx(
        address _from, 
        address _to,  
        uint256 _amount, 
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasToken,
        address _relayer,
        bool    _isContract,
        bytes memory _sig
    ) public returns (bool) {

        require(nonces[_from].add(1) == _nonce, "nonce out of order");
        
        require(tx.gasprice == _gasPrice); // set gas price of tx

        uint256 tokenFees = _gasToken.mul(_gasPrice).mul(50000); // should be changed.

        require(balanceOf(_from) >= _amount.add(tokenFees));

        bytes32 hash = keccak256(abi.encodePacked(
            SWINGBY_TX_TYPEHASH,
            _from,
            _to,
            _amount,
            _nonce
        ));
        
        address signer = SigUtil.recover(SigUtil.prefixed(hash), _sig);

        require(signer == _from, "signer != _from");


        nonces[_from] = nonces[_from].add(1);
        
        _transfer(_from, _to, _amount);

        _transfer(_from, _relayer, tokenFees);

        if (_isContract) {
            ITokensRecipient(_to).onTokenReceived(address(this), _from, _amount);
        }
    }
    
    function getNonce(address _from) public view returns (uint256 nonce) {
        return nonces[_from];
    }

    // after override functions
    function balanceOf(address who) public view returns (uint256);

    function _transfer(address _from, address _to, uint256 _amount) internal;    
}