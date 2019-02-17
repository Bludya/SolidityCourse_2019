pragma solidity >=0.4.22 <0.6.0;

contract ServiceMarket{
    address _owner;

    uint lastTimeBought;
    uint lastTimeWithdrawn;

    uint SERVICE_PRICE = 1 ether;
    uint SERVICE_TIME_SPACING = 2 minutes;
    uint MAX_AMOUNT_WITHDRAWN = 5 ether;
    uint WITHDRAW_TIME_SPACING = 1 hours;

    event ServiceBought(address indexed buyer, uint indexed timestamp);
    event ChangeReturned(address indexed buyer, uint indexed change, uint timestamp);
    event Withdrawal(uint indexed amount, uint timestamp);

    constructor() public {
        _owner = msg.sender;
        lastTimeBought = now - 2 minutes;
        lastTimeWithdrawn = now - 1 hours;
    }

    modifier owner(){
        require(isOwner(), 'Only owner function.');
        _;
    }

    modifier notOwner(){
        require(!isOwner(), 'Only not owner function.');
        _;
    }

    modifier withdrawable(){
        require(now > lastTimeWithdrawn + WITHDRAW_TIME_SPACING, 'You can withdraw once per hour.');
        _;
    }

    modifier buyable(){
        require(now > lastTimeBought + SERVICE_TIME_SPACING, 'Service not available at the moment.');
        _;
    }

    function isOwner() internal view returns (bool)  {
        return msg.sender == _owner;
    }

    function buy() public payable notOwner buyable {
        require(msg.value > SERVICE_PRICE, 'Unsufficient funds.');

        emit ServiceBought(msg.sender, now);
        lastTimeBought = now;

        uint change = msg.value - SERVICE_PRICE;

        if(change > 0){
            msg.sender.transfer(change);
            emit ChangeReturned(msg.sender, change, now);
        }
    }

    function withdraw(uint amount) public owner withdrawable {
        require(amount < MAX_AMOUNT_WITHDRAWN, 'Amount is above the limit.');
        require(amount < address(this).balance, 'Unsufficient funds.');

        emit Withdrawal(amount, now);

        lastTimeWithdrawn = now;
        msg.sender.transfer(amount);
    }
}
