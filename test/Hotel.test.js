// const { Accounts } = require("web3-eth-accounts");

// const { assert } = require("console");

let Hotel = artifacts.require("Hotel");

contract("Hotel", (accounts) => {
  before(async () => {
    instance = await Hotel.deployed();
  });
  //   Testing deployer
  it("should return accounts[0]", async () => {
    let deployer = await instance.deployer();
    assert.equal(deployer, accounts[0], "There was a mismatch");
  });
  //   Testing viewRoomPrice
  it("should return 0.02 ether", async () => {
    let length = await instance.viewRoomPrice(5);
    assert.equal(
      length,
      web3.utils.toWei("0.02", "ether"),
      "It is supposed to be 0.02 ether"
    );
  });
  //   Testing the constructor function
  it("should return 20", async () => {
    let rooms = await instance.viewAvailableRooms();
    assert.equal(rooms.length, 20, "The available rooms should be 20 ");
  });
  //   Testing booked before it is booked
  it("should return false", async () => {
    let booked = await instance.booked(2);
    assert.equal(
      booked,
      false,
      "It should be tagged false when not after been booked "
    );
  });
  //   Testing the bookRoom function
  it("should return 18", async () => {
    await instance.bookRoom(3, {
      value: web3.utils.toWei("0.01", "ether"),
      from: accounts[1],
    });
    await instance.bookRoom(2, {
      value: web3.utils.toWei("0.01", "ether"),
      from: accounts[1],
    });
    let rooms = await instance.viewAvailableRooms();

    assert.equal(
      rooms.length,
      18,
      "The available rooms should be 18 after a booking "
    );
  });
  //   Testing booked
  it("should return true", async () => {
    let booked = await instance.booked(2);
    assert.equal(booked, true, "It should be tagged true after been booked ");
  });
  it("should return false", async () => {
    let booked = await instance.booked(4);
    assert.equal(
      booked,
      false,
      "It should be tagged false when not after been booked "
    );
  });

  //   Testing viewOwnedRooms
  it("should return 2", async () => {
    let bookedRooms = await instance.viewOwnedRoom(accounts[1]);
    assert.equal(
      bookedRooms.length,
      2,
      "rooms should be pushed into an array "
    );
  });
  //   Testing timestamp
  it("should return true", async () => {
    let timeLeft = await instance.viewTimeLeft(accounts[1], 7);
    let time = (await instance.bookedTime()) + 60 * 3;
    time = time.toString();
    assert.equal(timeLeft, time, "The time is increased by 3 minutes ");
  });
});
