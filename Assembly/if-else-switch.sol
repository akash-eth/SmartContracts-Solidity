// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract IfStatement {

    function ifSolidity(uint _data) external pure returns(uint) {
        if(_data == 1) {
            return 10;
        }
        else if(_data == 2) {
            return 20;
        }
        return _data;
    }

    function ifAssembly(uint _data) external pure returns(uint returnValue) {
        assembly{
            switch _data
            case 1 {
                returnValue := 10
            }
            case 2 {
                returnValue := 20
            }
            default {
                returnValue := 1
            }
        }
    }

}