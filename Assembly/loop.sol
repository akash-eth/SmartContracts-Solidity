// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Loop {
    
    function loopSolidity(uint[] calldata _data) external pure returns(uint) {
        uint sum;
        for(uint i=0; i < _data.length; i++) {
            sum += _data[i];
        }
        return sum;
    }
    
    function loopAssembly(uint[] calldata _data) external pure returns(uint sum) {
        assembly {
            let length := mload(_data.length)
            let data := add(_data.length, 0x20)     // 0x20 represents 32 in bytes
            
            for 
                /* 
                    {initialized var}
                    stopping condition
                    {incerease on each pass}
                    
                    {
                        body of the loop
                    }
                */
                // we are adding end variable of the array !!
               {let end := add(data, mul(0x20, length))} 
               
               // lt means lower than
               lt (data, end)
               
               // Incrementing: this will be executing each tym after the body of the loop is exe. 
               {data := add(data, 0x20)}
               
               {
                   sum := add(sum, mload(data))
               }
        }
    }
}