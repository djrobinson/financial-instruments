pragma solidity ^0.4.17;

contract LoanFactory {
    address[] public deployedLoans;

    function createLoan(uint requestedRate, uint requestedAmount, uint lengthInPeriods, uint testPeriodLength) public {
        address newLoan = new Loan(requestedRate, requestedAmount, lengthInPeriods, testPeriodLength);
        deployedLoans.push(newLoan);
    }

    function getDeployedLoans() public view returns (address[]) {
        return deployedLoans;
    }
}