// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC1155.sol";
import "./IConditionalTokens.sol";

contract ConditionalTokenWallet is IERC1155TokenReceiver {
    
    IERC20 dai;
    IConditionalTokens conditionalTokens;
    address public oracle;
    address admin;
    
    mapping(bytes32 => mapping(uint => uint)) public tokenBalance; // put bytes32 then questionId, then you will get the balance !!
    
    constructor(
            address _dai, 
            address _condtionalTokens,
            address _oracle
        )  {
            dai = IERC20(_dai);
            conditionalTokens = IConditionalTokens(_condtionalTokens);
            oracle = _oracle;
            admin = msg.sender;
        }
        
        
    function  redeemTokens(
            bytes32 _conditionId,
            uint[] calldata _indexSets
        ) external {
            conditionalTokens.redeemPositions(
                dai,
                bytes32(0),
                _conditionId,
                _indexSets
                );
        }
        
    function transferDai(address _to, uint _amount) external {
        require(msg.sender == admin, 'only admin');
        dai.transfer(_to, _amount);
    }
        
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4) {
            return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
        }

    
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4) {
            return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
}