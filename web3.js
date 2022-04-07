let Web3 = require("web3");
let Tx = require("ethereumjs-tx");
let foster = new Web3("http://localhost:8545");
let fs = require("fs");
let dotenv = require("dotenv").config();
let path = "./build/contracts/Hotel.json";

let syncedFile = JSON.parse(fs.readFileSync(path));
let abi = syncedFile.abi;
let contractAddress = "0x25cDcd528E6F87DDe8fc67b42D74077Cc147D1dB";

let contract = new foster.eth.Contract(abi, contractAddress);
// const getStatus = async () => {
//   let booked = await contract.methods.roomPrice(1);
//   booked = await booked;
//   console.log(booked);
// };
console.log(contract.methods.roomPrice(1));
// getStatus();
