// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract Hotel {
    address payable public deployer;
    uint256 public bookedTime;
    mapping(address => uint256[]) roomOwnedBy;
    mapping(address => mapping(uint256 => uint256)) timestamp;
    uint256[] availableRoomsInstance;
    uint256 price;
    uint256[] availableRooms;
    mapping(uint256 => bool) public booked;
    struct hotelRoom {
        uint256 hotelRoom;
        uint256 roomPrice;
    }
    hotelRoom[] hotelRooms;
    event Transfer(address _from, address _to, uint256 _amount);

    constructor(uint256 _maxRoomNumber) {
        require(_maxRoomNumber <= 20);
        deployer = payable(msg.sender);
        for (uint256 i = 1; i <= _maxRoomNumber; i++) {
            if (i < 5) {
                price = 0.01 ether;
            } else if (i >= 5 && i < 10) {
                price = 0.02 ether;
            } else if (i >= 10 && i < 15) {
                price = 0.03 ether;
            } else {
                price = 0.04 ether;
            }
            hotelRooms.push(hotelRoom(i, price));
            availableRooms.push(i);
            booked[i] = false;
        }
    }

    function viewAvailableRooms() public view returns (uint256[] memory) {
        return availableRooms;
    }

    function bookRoom(uint256 _roomNumber) public payable {
        require(
            _roomNumber > 0 && _roomNumber <= hotelRooms.length,
            "Room unavailable"
        );
        require(msg.value >= hotelRooms[_roomNumber].roomPrice);
        require(booked[_roomNumber] != true);

        roomOwnedBy[msg.sender].push(_roomNumber);
        booked[_roomNumber] = true;

        // Removing room from available rooms
        delete availableRoomsInstance;
        for (uint256 i = 0; i < availableRooms.length; i++) {
            if (i != _roomNumber) {
                availableRoomsInstance.push(i);
            }
        }
        availableRooms = availableRoomsInstance;

        // Emitting the transfer and doing th transfer
        deployer.transfer(msg.value);
        emit Transfer(msg.sender, deployer, msg.value);

        //  Setting the time duration
        bookedTime = block.timestamp;
        timestamp[msg.sender][_roomNumber] = block.timestamp;
    }

    function viewRoomPrice(uint256 _roomNumber) public view returns (uint256) {
        return hotelRooms[_roomNumber - 1].roomPrice;
    }

    function viewOwnedRoom(address _address)
        public
        view
        returns (uint256[] memory)
    {
        return roomOwnedBy[_address];
    }

    function extendTimeSpan(uint256 _roomNumber) public {
        require(booked[_roomNumber] = true);
        // Making sure the person really owns the room
        bool ownedBySender = false;
        for (uint256 i = 0; i < roomOwnedBy[msg.sender].length; i++) {
            if (_roomNumber == _roomNumber) {
                ownedBySender = true;
            }
            require(ownedBySender == true);
        }
    }

    function viewTimeLeft(address _address, uint256 _roomNumber)
        public
        view
        returns (uint256)
    {
        return timestamp[_address][_roomNumber];
    }
    // function viewTimeStamps () public  {
    //     return
    // }
}
