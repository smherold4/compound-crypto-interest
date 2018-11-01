pragma solidity ^0.4.24;

contract Bank {

    struct Investment {
        uint deposited_at;
        int amount;
        int interest_rate;
        uint paid_at;
        int paid_amount;
    }

    struct Scientific {
      int base;
      int exp;
    }

    // Investment[] public investments;

    mapping (address => Investment) public investments;
    int public interest_rate;
    address public owner = msg.sender;
    uint public creationTime = now;

    constructor(int _interestRate) public {
        interest_rate = _interestRate;
    }

    function withdraw(address _investor, uint current_timestamp) public returns (bool) {
        // TODO investor should pay the txn fees, we should record those fees
        Investment memory investment = investments[_investor];
        require(investment.paid_at == 0);
        investment.paid_at = current_timestamp;
        investment.paid_amount = amountOwed(_investor);
        investments[_investor] = investment;
        return true;
    }

    function amountOwed(address _investor) public view returns (int) {
      Investment memory investment = investments[_investor];

      if (investment.paid_at != 0) {
        return 0;
      }
      Scientific memory r = Scientific(investment.interest_rate*1e11/100, -11); //interest rate
      Scientific memory n = Scientific(31536, 3); // seconds in a year

      Scientific memory periodic_rate = Scientific(r.base/n.base, r.exp - n.exp);
      periodic_rate.base = periodic_rate.base + 1.0e14; //we know the exp must be at -14 so we add Decimal(1e14, -14)

      uint num_periods = now - investment.deposited_at;
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
      return result.base;
    }

    function getInvestment(address _investor) public view returns (int, int, uint, uint, int) {
      Investment memory investment = investments[_investor];
      return (
        investment.amount,
        investment.interest_rate,
        investment.deposited_at,
        investment.paid_at,
        investment.paid_amount
      );
    }

    function setInterestRate(int _newInterestRate) public returns (bool) {
      require(msg.sender == owner);
      interest_rate = _newInterestRate;
      return true;
    }

    function() public payable {
      Investment memory investment = investments[msg.sender];
      investment.deposited_at = now;
      investment.amount = int(msg.value) + amountOwed(msg.sender);
      investment.interest_rate = interest_rate;
      investment.paid_at = 0;
      investment.paid_amount = 0;
      investments[msg.sender] = investment;
    }

}