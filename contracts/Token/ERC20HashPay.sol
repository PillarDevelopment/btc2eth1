pragma solidity 0.5.0;

import "./ERC20Detailed.sol";

/**
 * @title Meta Transaction
 * @dev 
 */

contract ERC20MetaTransaction is ERC20Detailed {

    mapping(address => uint) private nonces;

    function getNonce(address _from) public view returns (uint256 nonce) {
        return nonces[_from];
    }

    function transferMetaTx(
        address _from, 
        address _to,  
        uint256 _amount, 
        uint256 _nonce, 
        bytes memory _sig
    ) internal returns (bool) {
        require(nonces[_from]+1 == _nonce, "nonce out of order");

        bytes32 hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32",
            _from,
            _to,
            _amount,
            _nonce
        ));
        
        address signer = recover(hash, _sig);

        require(signer == _from, "signer != _from");

        nonces[_from] = nonces[_from].add(1);
        
        _transfer(_from, _to, _amount);

    }

    function recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
        if (sig.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }
}