pragma solidity 0.5.0;

/**
 * @title Constant 
 * @dev 
 */

contract Constant { 
    // Swingby Tx hash type
    //keccak256(
    //    "SwingbyTx(address _from,address _to,uint256 _amount,uint256 _nonce)"
    //);
    bytes32 public constant SWINGBY_TX_TYPEHASH = 0x199aa146523304760a88092ee1dd338a68f10185375827f1e838ab5e9bd1622b;
    // SWINGBY_STAKE_HASH
    // keccak256("SwingbyStakeStorageHash")
    bytes32 public constant SWINGBY_STAKE_HASH = 0xdb1067d644748022575f65db064c07c75804e4e625dcfc384d629569792def39;
}