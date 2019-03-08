pragma solidity 0.5.0;

import "../Utils/SigUtil.sol";
import "../Utils/SafeMath.sol";
import "./ITokensRecipient.sol";

/**
 * @title ERC20SimpleMetaTx
 * @dev 
 */

contract ERC20SimpleMetaTx {
    using SafeMath for uint256;

    struct GasReceipt {
        uint256 gasPrice;
        uint256 tokenPerWei;
    }

    mapping(address => uint) private nonces;

    mapping(address => GasReceipt) private relayers; // set gas price and token per wei;

    function setConfig(uint256 _gasPrice, uint256 _tokenPerWei) public {
        relayers[msg.sender] = GasReceipt({
            gasPrice: _gasPrice,
            tokenPerWei: _tokenPerWei
        });
    }

    function transferMetaTx(
        address _from, 
        address _to,  
        uint256 _amount, 
        uint256 _nonce,
        bool    _isContract,
        bytes memory _sig
    ) public returns (bool) {
        require(nonces[_from].add(1) == _nonce, "nonce out of order");

        require(relayers[msg.sender].gasPrice != 0x0, "gas price is not set");
        
        require(tx.gasprice == relayers[msg.sender].gasPrice);

        bytes32 hash = keccak256(abi.encodePacked(
            _from,
            _to,
            _amount,
            _nonce
        ));
        
        address signer = SigUtil.recover(SigUtil.prefixed(hash), _sig);

        require(signer == _from, "signer != _from");
    
        uint256 gasPrice = relayers[msg.sender].gasPrice;

        uint256 tokenPerWei = relayers[msg.sender].tokenPerWei;

        uint256 tokenFees = tokenPerWei.mul(gasPrice).mul(50000); // should be changed.

        nonces[_from] = nonces[_from].add(1);
        
        _transfer(_from, _to, _amount);
        _transfer(_from, msg.sender, tokenFees);

        if (_isContract) {
            ITokensRecipient(_to).onTokenReceived(address(this), _from, _amount);
        }
    }
    
    function getNonce(address _from) public view returns (uint256 nonce) {
        return nonces[_from];
    }

    function _transfer(address _from, address _to, uint256 _amount) internal;    
}