//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2; 

contract Oracle {
    
    //storing data:
    struct Result {
        bool exist;
        uint payload;
        address[] approvedBy;
    }
    
    address[] public validators;
    
    constructor(address[] memory _validators) {
        validators = _validators;
    }
    
    // mapping of Result:
    mapping(bytes32 => Result) private results;
    
    // will used to get data from outside !!
    function feedData(bytes32 _dataKey, uint _payload) external onlyValidator() {
        address[] memory approvedBy = new address[](1);
        approvedBy[0] = msg.sender;
        
        require(results[_dataKey].exist == false, 'Data already imported');
        results[_dataKey] = Result(true, _payload, approvedBy);
    }
    
    //this function eill be called by validators for approving the data in the oracle:
    function approveData(bytes32 _dataKey) external onlyValidator() {
        Result storage result = results[_dataKey];
        require(result.exist == true, 'can not approve non-existing data!!');
        for(uint i=0; i < result.approvedBy.length; i++) {
            require(result.approvedBy[i] != msg.sender, 'can not approve a data twice');
        }
        result.approvedBy.push(msg.sender);
    }
    
    // will be used by our Arbitrage contract to fetch data !!
    function getData(bytes32 _dataKey) external view returns(Result memory) {
        return results[_dataKey];
    }
    
    modifier onlyValidator() {
        bool isValidator = false;
        for(uint i=0; i < validators.length; i++) {
            if (validators[i] == msg.sender) {
                isValidator = true;
            }
        }
        require(isValidator == true, 'Only validator');
        _;
    }
    
}