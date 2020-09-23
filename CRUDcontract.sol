// SPDX-License-Identifier: Undefined

pragma solidity ^0.7.0;

contract crud {

    struct User {
        uint id;
        string name;
    }

    User[] public users;
    uint public nextId;

    function create(string memory name) public {
        users.push(User(nextId, name));
        nextId++;
    }

    function read(uint id) public view returns(uint, string memory) {
        for(uint i; i < users.length; i++) {
            if(users[i].id == id) {
                return (users[i].id, users[i].name) ;
            }
        }
    }

}