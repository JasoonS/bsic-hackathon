//@title hub
//@author Cary Small
pragma solidity ^0.4.2;

import './zeppelin/lifecycle/Killable.sol';
//contract that sponsers will be creating
import './UserContract.sol';

contract hub is Killable {
    bytes32[] identifierHashes;
    mapping(bytes32 => address) contracts;
    
    /**
    @notice gets the length of the user array
    @return uint length of the identifierHashes array
    @dev this array can be used in order to itterate over the contracts owned by each hash
    */
    function getUserCount() 
    constant
    returns (uint lengthOfIdentifiers)
    {
     return identifierHashes.length;  
    }
    
    /**
    @dev newUserContract creates a new contract
    @param _identifierHash the hashed value that wil be used to identify the person (eg his hashed name, email address etc)
    @param _dailyAllowance the amount of MANA the person wil get per day
    @param _dailyDepreciationRate the numerator for the deprecation function. 
    @return returns the address of the new contract
    */
    function newUserContract(bytes32 _identifierHash, uint _dailyAllowance, uint _dailyDepreciationRate) 
    returns (address newContract) {
        UserContract trustedContract = new UserContract(_identifierHash,_dailyAllowance,_dailyDepreciationRate);
        identifierHashes.push(_identifierHash);
        contracts[_identifierHash] = trustedContract;
        return trustedContract;
    }
    
    
    /**
     * @dev kills the contract at the address.
     * @param contractAddress is the address of the contract you want to remove
     * @return boolean value of whether it was successful
     */
    function killContract(address contractAddress) returns (bool succcess) {
        UserContract trustedContract = UserContract(contractAddress);
        trustedContract.kill();
        //either the code will throw an error or return true
        return true;
    }
    
    
} 