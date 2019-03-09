pragma solidity 0.5.0;

import "../Utils/SigUtil.sol";
import "../Utils/Constant.sol";
import "../Utils/SafeMath.sol";
import "./ITokensRecipient.sol";

/**
 * @title ERC20MetaTx
 * @dev 
 */

contract ERC20MetaTx is Constant {
    using SafeMath for uint256;

    mapping(address => uint) private nonces;

    uint256 public sendGasCost = 20000;

    function transferMetaTx(
        address _from, 
        address _to,  
        uint256 _amount, 
        uint256 _nonce,
        uint256[3] memory _inputs, // 0 => _gasPrice, 1 => _gasLimit, 2 => _gasTokenPerWei,
        address _relayer,
        address _tokenReceiver,
        bytes memory _sig
    ) public returns (bool) {

        uint256 initialGas = gasleft();

        require(_relayer == address(0) || _relayer == msg.sender, "wrong relayer");
        // need to give at least as much gas as requested by signer + extra to perform the call
        require(initialGas > _inputs[1] + sendGasCost, "not enought gas given");
        require(nonces[_from].add(1) == _nonce, "nonce out of order");
        // safeGas = gaslimit + sendGasCost * gasprice * _gasToenPerWei 
        uint maxFees = sendGasCost.add(_inputs[1]).mul(_inputs[0]).mul(_inputs[2]);
        require(balanceOf(_from) >= _amount.add(maxFees), "_from not enough balance");
        // need to provide same gasPrice as requested by signer
        require(tx.gasprice == _inputs[0], "gasPrice != signer gasPrice"); 
        
        bytes32 txHash = SigUtil.prefixed(keccak256(abi.encodePacked(
            SWINGBY_TX_TYPEHASH,
            _from,
            _to,
            _amount,
            _nonce,
            _inputs[0],
            _inputs[1],
            _inputs[2],
            _relayer
        )));
        
        address signer = SigUtil.recover(txHash, _sig);

        require(signer == _from, "signer != _from");

        _transfer(_from, _to, _amount);

        if (isContract(_to)) {
            ITokensRecipient(_to).onTokenReceived(address(this), _from, _amount);
        }
        // calculate _gasPrice * _gasTokenPerWei
        uint256 tokenFees = ((initialGas + sendGasCost) - gasleft()) * _inputs[0] * _inputs[2]; 
        _transfer(_from, _tokenReceiver, tokenFees);   
    }
    
    function getNonce(address _from) public view returns (uint256 nonce) {
        return nonces[_from];
    }

    function balanceOf(address who) public view returns (uint256);

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function _transfer(address _from, address _to, uint256 _amount) internal;    
}


