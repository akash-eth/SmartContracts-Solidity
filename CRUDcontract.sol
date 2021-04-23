// SPDX-License-Identifier: Undefined

pragma solidity >= 0.5.0;

contract CRUD {
    
    struct User {
        uint id;
        string name;
    }
    

    User[] public users;
    
    uint public nextId = 1;
    
    function create(string memory _name) public {
        users.push(User(nextId, _name));
    }
    
    function read(uint _id) view public returns(uint, string memory) {
        // now we have get user info based on IDs. So we'll need to implement loops
        // for(uint i; i < users.length; i++) {
        //     if(users[i].id == _id) {
        //         return (users[i].id, users[i].name);
        //     }
        // }
        uint i = findUser(_id);
        return (users[i].id, users[i].name);
    }
    
    function update(uint _id, string memory _updatedName) public {
        // for(uint i; i < users.length; i++) {
        //     if(users[i].id == _id) {
        //         users[i].name = _updatedName;
        //     }
        // }
        uint i = findUser(_id);
        users[i].name = _updatedName;
    }
    
    function deleteUser(uint _id) public {
        uint i = findUser(_id);
        delete users[i];
    }
    
    function findUser(uint _id) view public returns(uint) {
        for(uint i; i < users.length; i++) {
            if(users[i].id == _id) {
                return i;
            }
        }
        revert ('Sorry the user does not exist !!');
    }
}