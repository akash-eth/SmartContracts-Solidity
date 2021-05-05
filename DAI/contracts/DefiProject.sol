//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DefiProject {

    IERC20 dai;

    constructor(address daiAddress) {
        dai = IERC20(daiAddress);
    }

    function transferToken(address _recipient, uint _amount) external {
        dai.transfer(_recipient, _amount);
    }

}