//@title hub
//@author BlockPaperScissors
pragma solidity ^0.4.15;

import './zeppelin/lifecycle/Killable.sol';
//contract that sponsers will be creating
import './UserContract.sol';

contract Hub is Killable {
    bytes32[] identifierHashes;
    mapping(bytes32 => address) contracts;
    mapping(address => bool) contractExists;

    modifier onlyIfContract(address userContract) {
        require(contractExists[userContract] != true);
        _;
    }

    event LogNewUserContract(address indexed newContractAddress, bytes32 indexed usersIdentifierHash, uint dailyAllowance, uint dailyDepreciationRate);
    event LogKillUserContract(address indexed sender, address indexed contractAddress);
    event LogContractNewOwner(address indexed contractAddress, address indexed newOwner);

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
    function newUserContract(bytes32 _identifierHash,
        uint _dailyAllowance,
        uint _dailyDepreciationRate)
        returns (address newContract)
    {
        UserContract trustedContract = new UserContract(_identifierHash,_dailyAllowance,_dailyDepreciationRate);
        identifierHashes.push(_identifierHash);
        contractExists[trustedContract] = true;
        contracts[_identifierHash] = trustedContract;
        LogNewUserContract(trustedContract,_identifierHash,_dailyAllowance, _dailyDepreciationRate);
        return trustedContract;
    }

    // Pass-through Admin Controls

    /**
     * @dev Changges the owner of the contract
     * @param contractAddress the address of the contract
     * @param newOwner is the new owners address
     * @return boolean value of whether it was successful
     */
    function changeContractOwner(address contractAddress, address newOwner)
        onlyOwner
        onlyIfContract(contractAddress)
        returns(bool success)
    {
        UserContract trustedContract = UserContract(contractAddress);
        LogContractNewOwner(contractAddress,newOwner);
        return(trustedContract.changeOwner(newOwner));
    }

    /**
     * @dev kills the contract at the address.
     * @param contractAddress is the address of the contract you want to remove
     * @return boolean value of whether it was successful
     */
    function killContract(address contractAddress)
        returns (bool succcess)
    {
        UserContract trustedContract = UserContract(contractAddress);
        trustedContract.kill();
        LogKillUserContract(msg.sender, contractAddress);
        contractExists[contractAddress] = false;
        //either the code will throw an error or return true
        return true;
    }

    /**
     * @dev kills the contract owned by the identifier.
     * @param identifier is the person whos contract you want to identifier
     * @return boolean value of whether it was successful
     */
    function killContractByIdentifier(bytes32 identifier)
        returns (bool succcess)
    {
        address contactAddress = contracts[identifier];
        UserContract trustedContract = UserContract(contactAddress);
        trustedContract.kill();
        LogKillUserContract(msg.sender, trustedContract);
        //either the code will throw an error or return true
        return true;
    }
}
