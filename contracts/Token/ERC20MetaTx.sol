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

    uint256 public sendGasCost = 40000;

    event ExecutionFailed(bytes32 txHash);

    function transferMetaTx(
        address _from, 
        address _to,  
        uint256 _amount,  
        uint256[4] memory _inputs, // 0 => _gasPrice, 1 => _gasLimit, 2 => _tokenPrice, 3 => _nonce
        address _relayer,
        address _tokenReceiver,
        bytes memory _sig
    ) public returns (bool) {

        uint256 initialGas = gasleft();

        require(_relayer == address(0) || _relayer == msg.sender, "wrong relayer");
        // need to give at least as much gas as requested by signer + extra to perform the call
        require(initialGas > _inputs[1] + sendGasCost, "not enought gas given");
        require(nonces[_from].add(1) == _inputs[3], "nonce out of order");
        uint maxFees = sendGasCost.add(_inputs[1]).mul(1 ether).div(_inputs[2]);
        require(balanceOf(_from) >= _amount.add(maxFees), "_from not enough balance");
        // need to provide same gasPrice as requested by signer
        require(tx.gasprice == _inputs[0], "gasPrice != signer gasPrice"); 
        
        bytes32 txHash = SigUtil.prefixed(getTransactionHash(
            _from,
            _to,
            _amount,  
            _inputs, 
            _relayer, 
            _tokenReceiver
        ));

        address signer = SigUtil.recover(txHash, _sig);

        require(signer == _from, "signer != _from");

        bool success;
        if (isContract(_to)) {
            // function should be return bool (not throw)
            success = ITokensRecipient(_to).onTokenReceived(address(this), _from, _amount);
            if (success) {
                _transfer(_from, _to, _amount);
            } else {
                emit ExecutionFailed(txHash);
            }
        } else {
            _transfer(_from, _to, _amount);
            success = true;
        }
        nonces[_from] = _inputs[3];
        // calculate init gas - now gas * _tokenPrice
        uint256 tokenFees = initialGas.add(sendGasCost).sub(gasleft()).mul(_inputs[0]).mul(1 ether).div(_inputs[2]); 
        _transfer(_from, _tokenReceiver, tokenFees);   
        return success;
    }

    function getTransactionHash(
        address _from, 
        address _to,  
        uint256 _amount, 
        uint256[4] memory _inputs, // 0 => _gasPrice, 1 => _gasLimit, 2 => _tokenPrice, 3 => _nonce
        address _relayer,
        address _tokenReceiver
    )
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(
            SWINGBY_TX_TYPEHASH,
            _from,
            _to,
            _amount,
            _inputs[0],
            _inputs[1],
            _inputs[2],
            _inputs[3],
            _relayer,
            _tokenReceiver
        ));
    }
    
    function getNonce(address _from) public view returns (uint256) {
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


