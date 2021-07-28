const Web3 = require('web3');

const web3 = new Web3("http://localhost:8545");

const contractABI = [];

const contractAddress = "0x97B753290BABBF706B53d01961aACB2441d28627";

let simpleSmartContract = new web3.eth.Contract(contractABI, contractAddress);

console.log(simpleSmartContract);

web3.eth.getAccounts()
.then(result => (console.log(result)));