pragma solidity ^0.4.17;

contract FinancialFormulas {

    // USED TO KEEP DECIMAL PLACE PRECISION
    uint public constant d = 1000000000;

    function calculateSpcaFactor( uint rate, uint n, uint precision) public returns (uint) {
      uint s = 0;
      uint N = 1;
      uint B = 1;
      for (uint i = 0; i < precision; ++i){
        uint partOne = d * N / B ;
        s += partOne *  rate**i / 10000**i;
        N  = N * (n-i);
        B  = B * (i+1);
      }
      return s;
    }

    // Use uinternally to calculate future principal balances
    function balance( uint rate, uint period, uint nper, uint _pv, uint _fv) private returns (uint) {
        uint payment = pmt( rate, nper, _pv, _fv, false );
        uint newBalance = (( _pv * calculateSpcaFactor(rate, period, 20) ) - ( ( payment * 10000 / rate )  * ( calculateSpcaFactor(rate, period, 20)  - d ))) / d;
        return newBalance;
    }

    // FV(interest_rate, number_payments, payment, PV, Type)
    // TODO: INCLUDE PAYMENT IN CALCULATION
    function fv(uint rate, uint nper, uint payment, uint pv, bool _loanType) public returns (uint) {
            uint fv = calculateSpcaFactor(rate, nper, 20) * pv / d;
        return fv;
    }

    // PMT
    function pmt(uint _requestedRate, uint _nper, uint _requestedAmount, uint _fv, bool _loanType) public returns (uint) {
        uint numerator = calculateSpcaFactor(_requestedRate, _nper, 10) * _requestedAmount * _requestedRate / 10000;
        uint denominator = calculateSpcaFactor(_requestedRate, _nper, 10) - d;
        uint calculatedPayment = numerator / denominator;
        return calculatedPayment;
    }

    // PPMT
    function ppmt(uint _rate, uint _period, uint nper, uint _pv, uint _fv, bool _loanType) public returns (uint) {
        uint payment = pmt( _rate, nper, _pv, _fv, false );
        uint principalPayment = payment - ipmt(_rate, _period, nper, _pv, _fv, false);
        return principalPayment;
    }

    // IPMT(interest_rate, period, number_payments, PV, FV, Type)
    function ipmt(uint _rate, uint _period, uint _nper, uint _pv, uint _fv, bool _loanType) public returns (uint) {
        uint payment = pmt( _rate, _nper, _pv, _fv, false );
        uint interestPayment = payment + calculateSpcaFactor(_rate, _period - 1, 20)  / d * (balance(_rate, _period - 1, _nper, _pv, 0) * _rate / 10000 - payment);
        return interestPayment;
    }
}