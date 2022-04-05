// SPDX-License-Identifier:MIT
pragma solidity ^0.8.12;

contract Hotel {
    uint256 maxRoomNumber;
    address payable  deployer;
    mapping(uint256 => uint256)  timestamp;
    mapping(address => uint256)  discountToken;
    mapping(uint256 => bool) public booked;
    mapping(address => uint256) public loyaltyPoints;
    mapping(uint256 => address) public roomOwner;
    mapping(uint256 => uint256) public roomPrice;
    mapping(uint256 => uint256) internal roomLoyaltyPoints;

    constructor(uint256 _maxRoomNumber) {
        require(_maxRoomNumber <= 20);
        maxRoomNumber = _maxRoomNumber;
        deployer = payable(msg.sender);
        for (uint256 i = 1; i <= maxRoomNumber; i++) {
            if (i < 5) {
                roomPrice[i] = 0.01 ether;
                roomLoyaltyPoints[i] = 3;
            } else if (i >= 5 && i < 10) {
                roomPrice[i] = 0.02 ether;
                roomLoyaltyPoints[i] = 7;
            } else if (i >= 10 && i < 15) {
                roomPrice[i] = 0.03 ether;
                roomLoyaltyPoints[i] = 12;
            } else {
                roomPrice[i] = 0.04 ether;
                roomLoyaltyPoints[i] = 15;
            }
            booked[i] = false;
        }
    }

    event Transfer(address _from, address _to, uint256 _amount);

    function bookRoom(uint256 _roomNumber, uint256 _period) public payable returns(bool success) {
        require(
            _roomNumber > 0 && _roomNumber <= maxRoomNumber,
            "Room unavailable"
        );
        require(
            msg.value >= (_period / 30) * roomPrice[_roomNumber],
            "Insufficient Fund to complete purchase"
        );
        require(booked[_roomNumber] == false, "Room has already been booked");

        booked[_roomNumber] = true;
        roomOwner[_roomNumber] = msg.sender;

        // Emitting the transfer and doing th transfer
        deployer.transfer(msg.value);
        emit Transfer(msg.sender, deployer, msg.value);

        // Setting loyaltyPoints
        loyaltyPoints[msg.sender] +=
            (_period / 30) *
            roomLoyaltyPoints[_roomNumber];

        // Setting timestamp

        _period = _period * 60;
        timestamp[_roomNumber] = block.timestamp + _period;

        return true;
    }

    function transferRoomOwnership(address _address, uint256 _roomNumber)
        public returns(bool success)
    {
        require(roomOwner[_roomNumber] == msg.sender , "Can't transfer that doesn't belong to you");
        roomOwner[_roomNumber] = _address;
        return true;
    }

    function viewTimeLeft(uint256 _roomNumber) view public returns (uint256) {
        return timestamp[_roomNumber];
    }

    function extendTime(uint256 _roomNumber, uint256 _period) public payable returns(bool success) {
        require(roomOwner[_roomNumber] == msg.sender);
        require((_period / 30) * 0.01 ether <= msg.value);
        // Setting loyaltyPoints
        loyaltyPoints[msg.sender] +=
            (_period / 30) *
            roomLoyaltyPoints[_roomNumber];

        _period = _period * 60;
        timestamp[_roomNumber] += _period;
        return true;
    }

    function getDiscount() public payable returns (uint256) {
        require(loyaltyPoints[msg.sender] >= 200, "Not enough loyaltyPoints");
        uint256 token = uint256(keccak256("grabtoken")) % 10000000;
        discountToken[msg.sender] = token;
        loyaltyPoints[msg.sender] = 0;
        return token;
    }

    function bookWithDiscount(
        uint256 _discountToken,
        uint256 _roomNumber,
        uint256 _period
    ) public payable returns (bool success){
        require(
            discountToken[msg.sender] == _discountToken && _discountToken != 0,
            "Unrecognized token"
        );
        require(
            _roomNumber > 0 && _roomNumber <= maxRoomNumber,
            "Room unavailable"
        );
        require(
            // 10% percent off as discount
            msg.value >= (((_period / 30) * roomPrice[_roomNumber]) * 9) / 10,
            "Insufficient Fund to complete purchase"
        );
        require(booked[_roomNumber] == false, "Room has already been booked");
        discountToken[msg.sender] = 0;
        //  When claiming a discount no loyalty points are added

        booked[_roomNumber] = true;
        roomOwner[_roomNumber] = msg.sender;

        // Emitting the transfer and doing th transfer
        deployer.transfer(msg.value);
        emit Transfer(msg.sender, deployer, msg.value);

        // Setting timestamp
        _period = _period * 60;
        timestamp[_roomNumber] = block.timestamp + _period;

        return true;
    }
    function makeRoomAvilable(uint _roomNumber) public {
        require(block.timestamp  >= timestamp[_roomNumber] , "Session not expired");
        require(msg.sender == deployer , "Restricted to Deployer only");
        booked[_roomNumber] = false;
        delete timestamp[_roomNumber];
        delete roomOwner[_roomNumber];
    }
}
