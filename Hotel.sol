// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

contract Hotel {
    address payable public deployer;
    uint256 maxRoomNumber;
    uint256[] instanceOfOwnersRooms;
    mapping(address => uint256[]) roomOwnedBy;
    mapping(uint256 => uint256) timestamp;
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
        require(
            msg.value >= hotelRooms[_roomNumber].roomPrice,
            "Insufficient Fund to complete purchase"
        );
        require(booked[_roomNumber] == false, "Room has already been booked");
        roomOwnedBy[msg.sender].push(_roomNumber);
        booked[_roomNumber] = true;

        // Emitting the transfer and doing th transfer
        deployer.transfer(msg.value);
        emit Transfer(msg.sender, deployer, msg.value);

        // Removing room from available rooms
        delete availableRoomsInstance;
        for (uint256 i = 0; i < availableRooms.length; i++) {
            if (availableRooms[i] != _roomNumber) {
                availableRoomsInstance.push(availableRooms[i]);
            }
        }
        availableRooms = availableRoomsInstance;

        // Setting timestamp
        timestamp[_roomNumber] = block.timestamp;
    }

    function viewRoomPrice(uint256 _roomNumber) public view returns (uint256) {
        require(
            _roomNumber > 0 && _roomNumber <= maxRoomNumber,
            "Invalid room number specified"
        );
        return hotelRooms[_roomNumber - 1].roomPrice;
    }

    function viewOwnedRoom(address _address)
        public
        view
        returns (uint256[] memory)
    {
        return roomOwnedBy[_address];
    }

    function transferRoomOwnership(address _address, uint256 _roomNumber)
        public
    {
        require(_address != msg.sender, "Can't transfer room to yourself");
        require(booked[_roomNumber] == true, "Room isn't booked");
        for (uint256 i = 0; i < roomOwnedBy[msg.sender].length; i++) {
            if (_roomNumber == roomOwnedBy[msg.sender][i]) {
                // Removing rooms from the owner's rooms
                delete instanceOfOwnersRooms;

                for (uint256 j = 0; j < roomOwnedBy[msg.sender].length; j++) {
                    if (_roomNumber != roomOwnedBy[msg.sender][j]) {
                        instanceOfOwnersRooms.push(roomOwnedBy[msg.sender][j]);
                    }
                }
                roomOwnedBy[msg.sender] = instanceOfOwnersRooms;
                roomOwnedBy[_address].push(_roomNumber);
            }
        }
    }

    function viewTimeLeft(uint256 _roomNumber) public view returns (uint256) {
        require(booked[_roomNumber] == true, "Room hasn't been booked");
        return timestamp[_roomNumber];
    }

    function extendTime(uint256 _roomNumber) public payable {
        require(booked[_roomNumber] == true, "Room hasn't been booked");

        emit Transfer(deployer, msg.sender, msg.value);
        deployer.transfer(msg.value);
    }
}
