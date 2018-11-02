pragma solidity ^0.4.24;

contract Bank {

    struct Investment {
        uint deposited_at;
        uint amount;
        uint interest_rate;
        uint paid_at;
        uint paid_amount;
    }

    struct Scientific {
      int base;
      int exp;
    }

    event Deposit(
        address indexed _investor,
        uint _value
    );

    event Withdraw(
      address indexed _investor,
      uint _deposited_amount,
      uint _deposited_at,
      uint _paid_amount
    );
    // Investment[] public investments;

    mapping (address => Investment) public investments;
    uint public interest_rate;
    address public owner = msg.sender;
    uint public creationTime = now;

    constructor(uint _interestRate) public {
        interest_rate = _interestRate;
    }

    function withdraw(address _investor) public returns (bool) {
      Investment memory investment = investments[_investor];
      require(investment.paid_at == 0);
      investment.paid_at = now;
      investment.paid_amount = amountOwed(_investor);
      investments[_investor] = investment;

      _investor.transfer(investment.paid_amount);
      emit Withdraw(_investor, investment.amount, investment.deposited_at, investment.paid_amount);
      return true;
    }

    function amountOwed(address _investor) public view returns (uint) {
      Investment memory investment = investments[_investor];

      if (investment.amount == 0 || investment.paid_at != 0) {
        return 0;
      }
      Scientific memory r = Scientific(int(investment.interest_rate)*1e11/100, -11); //interest rate
      Scientific memory n = Scientific(31536, 3); // seconds in a year

      Scientific memory periodic_rate = Scientific(r.base/n.base, r.exp - n.exp);
      periodic_rate.base = periodic_rate.base + 1.0e14; //we know the exp must be at -14 so we add Decimal(1e14, -14)

      uint num_periods = now - investment.deposited_at;
      require(num_periods >= 0);

      Scientific memory result = Scientific(int(investment.amount), 0);

      for (uint i=1; i<=num_periods; i++) {
        result = Scientific(result.base*periodic_rate.base, result.exp + periodic_rate.exp);
        while (result.exp < -35) {
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
      return uint(result.base);
    }

    function getInvestment(address _investor) public view returns (uint, uint, uint, uint, uint) {
      Investment memory investment = investments[_investor];
      return (
        investment.amount,
        investment.interest_rate,
        investment.deposited_at,
        investment.paid_at,
        investment.paid_amount
      );
    }

    function setInterestRate(uint _newInterestRate) public returns (bool) {
      require(msg.sender == owner);
      interest_rate = _newInterestRate;
      return true;
    }

    function handlePayment(address sender, uint value) private {
      uint old_amount = amountOwed(sender);
      uint new_amount = value;
      Investment memory investment = Investment(
        now,
        new_amount + old_amount,
        interest_rate,
        0,
        0
      );
      investments[sender] = investment;
    }

    function() public payable {
      if (msg.sender != owner) {
        handlePayment(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
      }
    }

  }