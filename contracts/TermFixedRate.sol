pragma solidity ^0.4.17;

import {FinancialFormulas} from "./Formulas.sol";

contract TermFixedRate {
    address public borrower;
    uint public dateRequested;
    uint public dateActivated;
    uint public requestedRate;
    uint public requestedAmount;
    uint public principalBalance;
    address[] public contributors;
    mapping(address => uint) public contributions;
    uint public contributedAmount;
    uint public contributorCount;
    uint public lengthInPeriods;
    uint public payment;
    uint public collectedPayments;
    uint public amountToInterest;
    uint public amountToPrincipal;
    uint public paymentPeriodIterator;
    uint public currentPeriodIteration;
    uint public amountTilActivation;
    uint public testPeriodLength;
    bool public completeFlag;


    constructor(uint _requestedRate, uint _requestedAmount, uint _lengthInPeriods, uint _testPeriodLength, address formulasAddress) public payable {
        dateRequested = now;
        requestedRate = _requestedRate;
        requestedAmount = _requestedAmount;
        lengthInPeriods = _lengthInPeriods;
        amountTilActivation = _requestedAmount;
        testPeriodLength = _testPeriodLength;
        borrower = msg.sender;
        FinancialFormulas ff = FinancialFormulas(formulasAddress);
        payment = ff.pmt(requestedRate, lengthInPeriods, requestedAmount, 0, false);
    }

    function contribute() public payable {
        contributors.push(msg.sender);
        contributorCount++;
        if (msg.value >= amountTilActivation) {
            uint amountToRefund = msg.value - amountTilActivation;
            contributedAmount = contributedAmount + msg.value - amountToRefund;
            contributions[msg.sender] = msg.value - amountToRefund;
            amountTilActivation = 0;
            msg.sender.transfer(amountToRefund);
            activate();
        } else {
            contributions[msg.sender] = msg.value;
            contributedAmount += msg.value;
            amountTilActivation = amountTilActivation - msg.value;
        }
    }

    function activate() private {
        dateActivated = now;
        principalBalance = requestedAmount;
        address(borrower).transfer(address(this).balance);
    }

    function makePayment() public payable {
        currentPeriodIteration = (now - dateActivated) / testPeriodLength + 1;

        if (paymentPeriodIterator <= currentPeriodIteration) {
            // amountToInterest = calculateInterestPayment();
        }
        // Need to clean up vars in here to make less confusing
        uint payoffValue = principalBalance + amountToInterest;
        if (msg.value <= payoffValue) {
            if (msg.value > amountToInterest && paymentPeriodIterator < currentPeriodIteration ) {
                paymentPeriodIterator++;
            }
            amountToPrincipal = msg.value - amountToInterest;
            collectedPayments += msg.value;
            principalBalance = principalBalance - msg.value + amountToInterest;
        } else {
            completeFlag = true;
            uint amountToRefund = msg.value - payoffValue;
            uint amountToPayment = msg.value - amountToRefund;
            collectedPayments += amountToPayment;
            principalBalance = 0;
            msg.sender.transfer(amountToRefund);
            distributeCollections();
        }
    }

    function distributeCollections() public {
        uint totalContributions = address(this).balance;
        for (uint i = 0; i < contributorCount; i++) {
            uint contributed = contributions[contributors[i]];
            uint distributionAmount = totalContributions * contributed / contributedAmount;
            address(contributors[i]).transfer(distributionAmount);
        }
    }
}