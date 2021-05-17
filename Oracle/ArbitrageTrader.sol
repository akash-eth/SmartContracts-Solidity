//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2; 

import 'Dex.sol';
import 'Oracle.sol';

contract ArbitrageTrader {
    
    // Adding a struct to hold asset:
    struct Asset {
        string name;
        address dex;    // address of the dex where you will trading your tokens !!
    }
    
    // declaring maping of struct Asset: Key => String, Value => Asset:
    mapping(string => Asset) public assets;
    
    address public admin;
    address public oracle;
    
    constructor()  {
        admin = msg.sender;
    }
    
    // Configuring our Oracle's contract address:
    function configureOracle(address _oracle) public onlyAdmin() {
        oracle = _oracle;
    }
    
    function configureAsset(Asset[] calldata _assets) external {
        for(uint i=0; i < _assets.length; i++) {
            assets[_assets[i].name] = Asset(_assets[i].name, _assets[i].dex);
        }
    }
    
    function maybeTrade(
        string calldata _sticker,
        uint _date
        ) external {
             
            Asset storage asset = assets[_sticker];
            
            // checking that dex address is not zero !!
            require(asset.dex != address(0));
            
            // get latest price from the oracle 
            bytes32 dataKey = keccak256(abi.encodePacked(_sticker, _date));
            Oracle oracleContract = Oracle(oracle); // we get this from the above fn configureOracle !!
            Oracle.Result memory result = oracleContract.getData(dataKey);
            require(result.exist == true, 'No data available, Can not trade');
            require(result.approvedBy.length >= 3, 'Not enough approvals, can not trade');
            
            // if there is a price, trade with dex
            Dex dexContract = Dex(asset.dex);
            uint price = dexContract.getPrice(_sticker);
            uint amount = 1 ether / price;

            // Making transaction:
            if (price > result.payload) {
                dexContract.sellToken(_sticker, amount, (99 * price) / 100);
            }
            else if (price < result.payload) {
                dexContract.buyToken(_sticker, amount, (101 * price) / 100);
            }
        }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, 'OnlyAdmin');
        _;
    }
     
}