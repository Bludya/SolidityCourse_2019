pragma solidity >=0.4.22 <0.6.0;

contract Auction {
    address _owner;
    address highestBidder;

    struct Bid {
        uint amount;
        uint bidTime;
    }

    mapping(address => Bid) bids;

    uint minimumDifference;
    uint startTime;
    uint endTime;
    bool isCanceled;

    event BidPlaced(address indexed bidder, uint indexed amount, uint indexed timestamp);
    event FundsWithdrawn(address indexed bidder, uint indexed amount);
    event AuctionCanceled();

    constructor(uint start, uint end, uint bidMargin) public {
        require(start > now && end > start, 'Incorrect start and end times.');
        startTime = start;
        endTime = end;
        _owner = msg.sender;
        highestBidder = address(0);
        isCanceled = false;
        minimumDifference = bidMargin;
    }

    modifier owner(){
        require(isOwner(), 'Only owner function.');
        _;
    }

    modifier notOwner(){
        require(!isOwner(), 'Only not owner function.');
        _;
    }

    modifier notCanceled(){
        require(!isCanceled, 'Auction is canceled.');
        _;
    }

    modifier notExpired(){
        require(!isExpired(), 'Auction expired.');
        _;
    }

    modifier expiredOrCanceled(){
        require(isCanceled || isExpired(), 'Auction is still active.');
        _;
    }

    modifier canBid(){
        uint bidTimeRequirement = bids[msg.sender].bidTime + 3600 seconds;
        require(bidTimeRequirement < now, 'There is a 1 hour spacing between bids.');
        _;
    }

    function isOwner() internal view returns (bool)  {
        return msg.sender == _owner;
    }

    function isExpired() internal view returns (bool){
        return now > endTime;
    }

    function getHighestBid() public view returns (uint){
        if(highestBidder == address(0)){
            return 0;
        }

        return bids[highestBidder].amount;
    }

    function getHighestBidder() public view returns (address){
        return highestBidder;
    }

    function placeBid() public payable notOwner notExpired notCanceled canBid{
        uint totalAmount = bids[msg.sender].amount + msg.value;
        require(totalAmount > getHighestBid() + minimumDifference, 'Bid is big enough.');

        highestBidder = msg.sender;
        bids[msg.sender] = Bid(totalAmount, now);
        emit BidPlaced(msg.sender, totalAmount, now);
    }

    function cancelAuction() public owner notCanceled notExpired{
        isCanceled = true;
        emit AuctionCanceled();
    }

    function withdrawFunds(address payable receiver) public expiredOrCanceled {
        uint amount;
        address withdrawalAccount = msg.sender;

        if(isCanceled){
            amount = bids[msg.sender].amount;
        }else if(isExpired()){
            require(highestBidder != msg.sender, 'Highest bidder can\'t withdraw the bid.');

            if(isOwner()){
                amount = bids[highestBidder].amount;
                withdrawalAccount = highestBidder;
            }else{
                amount = bids[msg.sender].amount;
            }
        }

        require(amount > 0, 'There are no funds for withdrawal for that address.');

        bids[withdrawalAccount].amount = 0;
        receiver.transfer(amount);
        emit FundsWithdrawn(msg.sender, amount);
    }
}
