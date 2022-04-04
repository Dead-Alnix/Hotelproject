let Hotel = artifacts.require("Hotel");

contract("Hotel", (accounts) => {
  before(async () => {
    instance = await Hotel.deployed();
  });
  // Testing deployer
  it("should return accounts[0] as the address of the deployer", async () => {
    let deployer = await instance.deployer();
    assert.equal(deployer, accounts[0], "There was a mismatch");
  });
  //   Testing viewRoomPrice
  it("should return 0.02 ether", async () => {
    let price = await instance.roomPrice(5);
    assert.equal(
      price,
      web3.utils.toWei("0.02", "ether"),
      "It is supposed to be 0.02 ether"
    );
  });
  // Testing booked before it is booked
  it("should return false when room is not booked ", async () => {
    let booked = await instance.booked(2);
    assert.equal(
      booked,
      false,
      "It should be tagged false when not after been booked "
    );
  });
  // Testing the roomOwner
  it("should return accounts[2] as the owner of the room 3", async () => {
    await instance.bookRoom(3, 30, {
      value: web3.utils.toWei("0.01", "ether"),
      from: accounts[2],
    });
    await instance.bookRoom(2, 30, {
      value: web3.utils.toWei("0.01", "ether"),
      from: accounts[1],
    });
    await instance.bookRoom(12, 60, {
      value: web3.utils.toWei("0.07", "ether"),
      from: accounts[1],
    });
    let roomOwner = await instance.roomOwner(3);

    assert.equal(
      roomOwner,
      accounts[2],
      "The owner of the room should be accounts[2] "
    );
  });
  it("should return accounts[1] as the owner of the room 12 ", async () => {
    let roomOwner = await instance.roomOwner(12);

    assert.equal(
      roomOwner,
      accounts[1],
      "The owner of the room should be accounts[2] "
    );
  });
  //   Testing booked
  it("should return true after the room is booked", async () => {
    let booked = await instance.booked(2);
    assert.equal(booked, true, "It should be tagged true after been booked ");
  });
  it("should return false even tho some rooms are booked but not this particular room", async () => {
    let booked = await instance.booked(4);
    assert.equal(
      booked,
      false,
      "It should be tagged false when not after been booked "
    );
  });
  // Testing transferRoomOwnership
  it("should return account[3] after transferring ownership to account[3]", async () => {
    await instance.transferRoomOwnership(accounts[3], 2, { from: accounts[1] });
    let owner = await instance.roomOwner(2);
    assert.equal(owner, accounts[3], "It should be accounts[3] ");
  });

  // Testing the viewTimeLeft
  it("should return timestamp + 30 minutes", async () => {
    let time = await instance.viewTimeLeft.call(2);
    time = await time.toString();
    let dead = await instance.blockTimestamp(2);
    dead = parseInt(await dead.toString()) + 30 * 60;
    assert.equal(time, dead, "Timestamp should increase by 30 minutes");
  });
  it("should return timestamp + 60 minutes", async () => {
    let time = await instance.viewTimeLeft.call(12);
    time = await time.toString();
    let dead = await instance.blockTimestamp(12);
    dead = parseInt(await dead.toString()) + 60 * 60;
    assert.equal(time, dead, "Timestamp should increase by 60 minutes");
  });
  // Testing the extendTime
  it("should return the timestamp + 60 minutes after time extension", async () => {
    let time = await instance.viewTimeLeft.call(2);
    time = parseInt(await time.toString()) + 60 * 60;
    await instance.extendTime(2, 60, {
      from: accounts[3],
      value: web3.utils.toWei("0.03", "ether"),
    });
    let newTime = await instance.viewTimeLeft.call(2);
    newTime = await newTime.toString();
    assert.equal(time, newTime, "It should be timestamp + 60 ");
  });
  // Testing loyalty Points
  it("should return 30 loyalty points", async () => {
    let points = await instance.loyaltyPoints(accounts[1]);
    points = points.toString();
    assert.equal(points, 30, "After booking rooms that are ");
  });
});
