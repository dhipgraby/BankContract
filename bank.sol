pragma solidity ^0.6.0;
import "./Ownable.sol";
import "./ERC20.sol";

/*
BANK
a) Create a struct for customers data. (account name, bank account, balance)
b) Create a private variable to save the balance of the bank.
c) Create a private variable for the bank fee.
d) Create a modifier for a payable cost.
d) Create a function to add a new customer, charge a cost to deposit into the bank and charge the bank fee.
d) Create a function to deposit funds into a customer account.
d) Create a function only for the contract owner to show the balance of the bank.
d) A function to show the information of a customer.
d) Create Events for: new customer, deposits, transfers, etc...

*/
contract myBank is Ownable, is ERC20{
    //customer struct
    struct Customer{
        string account_name;
        address account_bank;
        uint balance;
        uint savings;
    }

    //Events
    event alertNewCustomer(string _name);
    event Transfer(string _name, address _from, address _to);
    event Deposit(string _name, address _to);
    event WithDraw(string _name, address _to);

    //bank balance, private
    uint private _bank_balance;
    //bank fee example
    uint private _bankFee = 0.1 ether;
    //minimum balance an account must have
    uint private _minBalance = 0.4 ether;
    //to storage fees charges
    uint private _bankService;
    //mapping address to customer
    mapping(address => Customer) private _customer;

    //set minimum price
    modifier costs(uint _cost){
        require(msg.value >= _cost);
        _;
    }

    //create a new customer, msg.sender
    function createCustomer(string memory _name) public payable costs(0.5 ether){
        Customer memory newCustomer;
        uint _toDeposit = msg.value - _bankFee;
        _bank_balance += _toDeposit;
        _bankService += _bankFee;

        newCustomer.account_name = _name;
        newCustomer.account_bank = msg.sender;
        newCustomer.balance = _toDeposit;
        newCustomer.savings = 0;
        _customer[msg.sender] = newCustomer;
        emit alertNewCustomer(_name);
    }
    //check bank balance
    function bankBalance() public view returns(uint){
      return _bank_balance;
    }

    //onlyOwner can check bank service
    function bankSrvc() public view onlyOwner returns(uint){
      return _bankService;
    }
    //get customer data from mapping
    function getCustomer() public view returns(string memory, address, uint, uint){
      address _creator = msg.sender;
      return(_customer[_creator].account_name, _customer[_creator].account_bank, _customer[_creator].balance, _customer[_creator].savings);
    }

    //transfer from one account to another, msg.sender required
    function transferFunds(address _recipient, uint256 _amount) public returns (bool) {
        require(_recipient == _customer[_recipient].account_bank, "Account not registered in our bank");
        require(_recipient != address(0), "Cant transfer to zero address");
        require(_customer[msg.sender].balance >= _amount, "Insufficient balance");
        require(_customer_customer[msg.sender].balance || _customer[msg.sender].savings > _minBalance, "Must have a minimum balance.");
        uint _amountToTransfer = _amount - _bankFee;
        //bank always charge to someone, this case must pay the msg.sender from his bank account
        _bank_balance -= _bankFee;
        _bankService += _bankFee;

        _customer[msg.sender].balance -= _amount;
        _customer[_recipient].balance += _amountToTransfer;

        emit Transfer(_customer[_recipient].account_name, msg.sender, _recipient);
        return true;
    }

    //deposit funds to bank account, msg.sender & msg.value
    function depositFunds() public payable returns(bool){
        require(msg.value >= _bankFee, "Insufficient Balance to deposit");
        uint _amountToDeposit = msg.value - _bankFee;
        _bank_balance += _amountToDeposit;
        _bankService += _bankFee;
        _customer[msg.sender].balance += _amountToDeposit;

        emit Deposit(_customer[msg.sender].account_name, msg.sender);
    }

    //withdraw funds from bank account
    function withdrawFunds(uint _amount) public returns(bool){
      require(_amount <= _customer[msg.sender].balance, "Not Enough balance to withdraw");
      uint _amountToWdraw = _amount - _bankFee;
      _bank_balance -= _amount;
      _bankService += _bankFee;
      _customer[msg.sender].balance -= _amount;
      msg.sender.transfer(_amountToWdraw);
      return true;
    }

    //withdraw all funds from contract, onlyOwner
    function withdrawOwner() public onlyOwner{
        uint _toTransfer = _bankService;
        _bankService = 0;
        msg.sender.transfer(_toTransfer);
    }
}
