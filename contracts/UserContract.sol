pragma solidity ^0.4.15;

import './zeppelin/lifecycle/Killable.sol';

contract UserContract is Killable {
    // a hash of some identifier to deter people from creating multiple accounts. (could be a hash of their ID number, or even some other biometric information)
    bytes32 public identifierHash;

    event LogNewOwner(address sender, address contractAddress, address newOwner);

    uint public balance; // the balance of this user.

    // TODO:: Write your own 'safemath' library that works on int (not only uint)
    mapping (address => int) public mainZeroSumLedger; // NOTE:: In future versions of the contract I want users to be able to generate their own ledgers and use them for whatever they want.

    // The contract is 'lazy', only it only updates it's state when the user asks it to.
    // The time of last update is important in culculating the current state.
    // NOTE:: this is updated via the block's timestap. Be very careful, miners can have different times (aparently even up to an hour of difference). Write code accordingly.
    //      I read somewhere that the time difference can be at most 900 seconds off, but this might be wrong.
    //      The acuracy of blocktimes is likely to get better with PoS as the consensys algorithm tightens.
    uint public timeOfLastUpdate;

    // TODO:: this should eventually go into the hub contract (for global configuration)
    uint public dailyDepreciationRate; //represented as a number out of 10^3 (make this more as needed)
    uint public dailyKeepRate; // just `10^3 - dailyDepreciationRate`

    uint public dailyAllowance; // variable stores the users daily allowance. (more advanced parameters to come)

    function UserContract(
        bytes32 _identifierHash,
        uint _dailyAllowance,
        uint _dailyDepreciationRate /*represented as a number out of 10^3*/
    ) {
        identifierHash = _identifierHash;
        dailyAllowance = _dailyAllowance;
        dailyDepreciationRate = _dailyDepreciationRate;
        dailyKeepRate = 1000 - _dailyDepreciationRate;
        timeOfLastUpdate = block.timestamp;
    }

    // NOTE: This is not working properly yet. (this function will require lots of TLC)
    function updateBalance()
        external
        onlyOwner
        returns(uint)
    {
        uint numDays = 0;
        if (block.timestamp > timeOfLastUpdate) {
            numDays = this.getNumDaysSinceUpdate(block.timestamp);

            timeOfLastUpdate = block.timestamp;
        }

        uint numeratorPow;
        uint denominatorPow;
        (numeratorPow,denominatorPow) = fractionPower(dailyKeepRate, 1000, numDays);

        // NOTE:: the maths over here will likely get reasonably complicated. -- see speadsheet.
        //TODO:: Think about predefining the ratio^power part to some common values, to prevent overflow.
        uint remainingAfterDepreciation = balance *(numeratorPow)/denominatorPow;
        uint manaPayout = dailyAllowance*((denominatorPow - numeratorPow)*1000)/(denominatorPow*dailyDepreciationRate);

        balance = remainingAfterDepreciation + manaPayout;
        return balance;
    }

    /**
    @dev fractionPower safely returns the result of taking a fraction to the power
    @param numerator of the fraction
    @param denominator of the fraction
    @param power the power of the entire fraction
    @return uint power of the fraction in numerator and denominator
    */
    function fractionPower(uint numerator, uint denominator, uint power)
        constant
    returns(uint resultNumerator, uint resultDenominator) {
        return (numerator**power, denominator**power);
    }

    /**
    @dev fractionPower safely returns the result of taking a fraction to the power
    @param numerator of the fraction
    @param denominator of the fraction
    @param power the power of the entire fraction
    @return uint power of the fraction in numerator and denominator
    */
    function getNumDaysSinceUpdate(uint timeNow)
        constant
        external
        returns (uint)
    {
        require(timeNow > timeOfLastUpdate);
        return (timeNow - timeOfLastUpdate)/86400;//86400 = 24*60*60
    }

    function changeOwner(address newOwner)
        onlyOwner
        returns (bool success)
    {
        require(newOwner != 0);
        LogNewOwner(msg.sender, owner, newOwner);
        owner = newOwner;
        return true;
    }
}
