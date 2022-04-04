// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

contract Hotel {
    address payable public deployer;
    uint256 price;
    mapping(uint256 => uint256) public blockTimestamp;
    uint256 maxRoomNumber;
    mapping(uint256 => bool) public booked;
    mapping(address => uint256) public loyaltyPoints;
    mapping(uint256 => address) public roomOwner;
    mapping(uint256 => uint256) timestamp;
    mapping(uint256 => uint256) public roomPrice;

    constructor(uint256 _maxRoomNumber) {
        require(_maxRoomNumber <= 20);
        maxRoomNumber = _maxRoomNumber;
        deployer = payable(msg.sender);
        for (uint256 i = 1; i <= maxRoomNumber; i++) {
            if (i < 5) {
                price = 0.01 ether;
            } else if (i >= 5 && i < 10) {
                price = 0.02 ether;
            } else if (i >= 10 && i < 15) {
                price = 0.03 ether;
            } else {
                price = 0.04 ether;
            }
            roomPrice[i] = price;
            booked[i] = false;
        }
    }

    event Transfer(address _from, address _to, uint256 _amount);

    function settingloyaltyPoints(uint256 _roomPrice) internal {
        if (roomPrice == 0.01 ether) {}
    }

    function bookRoom(uint256 _roomNumber, uint256 _period) public payable {
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
        loyaltyPoints[msg.sender] += (_period / 30) * 10;

        // Setting timestamp

        _period = _period * 60;
        timestamp[_roomNumber] = block.timestamp + _period;
        blockTimestamp[_roomNumber] = block.timestamp;
    }

    function transferRoomOwnership(address _address, uint256 _roomNumber)
        public
    {
        require(roomOwner[_roomNumber] == msg.sender);
        roomOwner[_roomNumber] = _address;
    }

    function viewTimeLeft(uint256 _roomNumber) public returns (uint256) {
        require(booked[_roomNumber] = true);
        return timestamp[_roomNumber];
    }

    function extendTime(uint256 _roomNumber, uint256 _period) public payable {
        require(roomOwner[_roomNumber] == msg.sender);
        require((_period / 30) * 0.01 ether <= msg.value);
        _period = _period * 60;
        timestamp[_roomNumber] += _period;
    }

    function getDiscount() public {}
}
