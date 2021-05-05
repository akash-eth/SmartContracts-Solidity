//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dai is ERC20 {

    constructor() ERC20("Dai StableCoin", "DAI") {}

    function getFaucet(address _recipient, uint _amount) external {
        _mint(_recipient, _amount);
    }

}