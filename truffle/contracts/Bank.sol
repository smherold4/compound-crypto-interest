/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/

pragma solidity ^0.4.24;

contract Bank {

    struct Investment {
        address investor;
        uint deposited_at;
        int amount;
        int interest_rate;
        uint paid_at;
    }

    struct Scientific {
      int base;
      int exp;
    }

    // Investment[] public investments;

    mapping (address => int) public balances;
    mapping (address => Investment) public investments;
    string public symbol;

    constructor(string _tokenSymbol) public {
        symbol = _tokenSymbol;
    }

    function pay(address _investor, uint current_timestamp) public returns (bool) {
        Investment memory investment = investments[_investor];
        require(investment.paid_at == 0);
        balances[investment.investor] += 100000000;//amountOwed(_investor, current_timestamp);
        investment.paid_at = current_timestamp;
        investments[investment.investor] = investment;
        return true;
    }

    function amountOwed(address _investor, uint current_timestamp) public view returns (int, int) {
      Investment memory investment = investments[_investor];
      Scientific memory r = Scientific(investment.interest_rate*1e11/100, -11); //interest rate
      Scientific memory n = Scientific(31536, 3); // seconds in a year

      Scientific memory periodic_rate = Scientific(r.base/n.base, r.exp - n.exp);
      periodic_rate.base = periodic_rate.base + 1.0e14; //we know the exp must be at -14 so we add Decimal(1e14, -14)

      uint num_periods = current_timestamp - investment.deposited_at;
      require(num_periods >= 0);

      Scientific memory result = Scientific(investment.amount, 0);

      int corrects = 0;

      for (uint i=1; i<=num_periods; i++) {
        result = Scientific(result.base*periodic_rate.base, result.exp + periodic_rate.exp);
        while (result.exp < -35) {
          corrects += 1;
          result = Scientific(result.base/10, result.exp + 1);
        }
      }

      while(result.exp != 0) {
        if(result.exp > 0) {
          result.base = result.base*10;
          result.exp = result.exp - 1;
        } else {
          result.base = result.base/10;
          result.exp = result.exp + 1;
        }
      }
      return (result.base, corrects);
    }

    function invest(address _investor, int _amount, int _interest_rate) public returns (bool) {
       Investment memory investment = Investment(
         _investor,
         block.timestamp,
         _amount,
         _interest_rate,
         0
       );
       investments[_investor] = investment;
       return true;
    }

    //views

    function balanceOf(address _investor) public view returns (int balance) {
        return balances[_investor];
    }

    function getInvestmentAmount(address _investor) public view returns (int) {
      Investment memory investment = investments[_investor];
      return investment.amount;
    }

    function getInvestmentDepositedAt(address _investor) public view returns (uint) {
      Investment memory investment = investments[_investor];
      return investment.deposited_at;
    }

    function getInvestmentPaidAt(address _investor) public view returns (uint) {
      Investment memory investment = investments[_investor];
      return investment.paid_at;
    }

    function getInvestmentInterestRate(address _investor) public view returns (int) {
      Investment memory investment = investments[_investor];
      return investment.interest_rate;
    }

}