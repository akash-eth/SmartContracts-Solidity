pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/token/ERC20/IERC20.sol";
import "./ComptrollerInterface.sol";
import "./CTokenInterface.sol";
contract DefiProject {
    
    IERC20 dai;
    CTokenInterface cDai;
    
    IERC20 bat;
    CTokenInterface cBat;
    
    ComptrollerInterface comptroller;
    
    constructor(
        address _dai,
        address _cDai,
        address _bat,
        address _cBat,
        address _comptroller
        ) public {
            dai = IERC20(_dai);
            cDai = CTokenInterface(_cDai);
            bat = IERC20(_bat);
            cBat = CTokenInterface(_cBat);
            comptroller = ComptrollerInterface(_comptroller);
        }
        
    function invest(uint _investAmount) external {
        dai.approve(address(cDai), 1000000);
        cDai.mint(_investAmount);
    }
    
    function redeem() external {
        uint balance = cDai.balanceOf(address(this));
        cDai.redeem(balance);
    }
    
    function borrow() external {
        address[] storage markets = new address[](1);
        markets[0] = address(cBat);
        
        comptroller.enterMarkets(markets);
        
        cBat.borrow(100);
    }
    
    function repay() public {
        bat.approve(address(cBat), 200);    // always keep the amount enough !!
        cBat.repayBorrow(100);
        
        // to back the balance:
        uint balance = cDai.balanceOf(address(this));
    }
    
}