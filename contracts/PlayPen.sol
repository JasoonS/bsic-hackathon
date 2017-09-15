pragma solidity ^0.4.15;

contract PlayPen {
    function fractionPower(uint numerator, uint denominator, uint power)
        constant
        returns(uint resultNumerator, uint resultDenominator) 
    {
        return (numerator**power, denominator**power);
    }

    // --------------------------------------------
    // ------------Tests not part of app-----------
    // --------------------------------------------

    // test inputs::
    // 5, 5, 5, 50
    // 50, 5, 5, 50
    // 100, 5, 5, 50
    // 150, 5, 5, 50
    // 500, 5, 5, 50
    // NOTE:: this function is ONLY for testing purposes and making sure that the maths is good. Delete ASAP.
    function updateBalanceTest(uint numDays, uint testBalance, uint dailyAllowance, uint dailyDepreciationRate)
        external
        constant
        returns(uint)
    {
        uint dailyKeepRate = 1000 - dailyDepreciationRate;

        uint numeratorPow;
        uint denominatorPow;
        (numeratorPow,denominatorPow) = fractionPower(dailyKeepRate, 1000, numDays);

        uint remainingAfterDepreciation = testBalance *(numeratorPow)/denominatorPow;
        uint manaPayout = dailyAllowance*((denominatorPow - numeratorPow)*1000)/(denominatorPow*dailyDepreciationRate);

        return remainingAfterDepreciation + manaPayout;
    }
}
