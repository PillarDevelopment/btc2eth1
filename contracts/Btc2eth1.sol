pragma solidity ^0.5.0;

import "./Token/Token.sol";
import "./Utils/SigUtil.sol";


contract Btc2eth1 {

    /**
     * message format
     * // txHash = SwingbyTx(address _lender)
     */
    mapping(bytes32 => bytes32) private orderState;
    mapping(uint256 => bytes32) private wshs; // sha256 hash
    
    Token private token;
    
    // not broadcasting deposit tx.
    function matchOrder(
        address _lender,
        address _minter, 
        uint256 _satohis, 
        bytes32 _wsh, 
        bytes32 _lsh, 
        bytes32 _msh,
        bytes32 _lenderTxId,
        bytes32 _minterTxId,
        bytes memory _lenderSig,
        bytes memory _minterSig
    ) public {
        bytes32 lenderTx = SigUtil.prefixed(keccak256(abi.encodePacked(
            _lender, 
            _satohis, 
            _wsh, 
            _lsh,
            _lenderTxId
        )));
        address lender = SigUtil.recover(lenderTx, _lenderSig);
        require(lender == _lender, "lender != _lender");

        bytes32 minterTx = SigUtil.prefixed(keccak256(abi.encodePacked(
            lenderTx,
            _msh,
            _minterTxId
        )));
        address minter = SigUtil.recover(minterTx, _minterSig);
        require(minter == _minter, "minter != _minter");

        
        require(orderState[_lsh] == 0x0);
        orderState[_lsh] = keccak256(abi.encodePacked(_wsh, _satohis)); // add secret hash to orderState with satoshis
    }

}