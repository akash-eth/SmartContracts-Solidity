// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC1155.sol";
import "./IConditionalTokens.sol";

contract DefiProject {
    
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
    
    function createBet(bytes32 _questionId, uint _amount) external {
        conditionalTokens.prepareCondition(
            oracle,
            _questionId,
            3   // number of outcomes !!
            );
            
        bytes32 conditionId = conditionalTokens.getConditionId(
            oracle,
            _questionId,
            3
            // if you wanted to create more sub-question(portions) you'll need to make a similar chain inside !!
            );
            
        /* partition argument explained:
            
            A, B, C     posiible outcomes
            partition => an array storing these possible outcomes:
            [A,B|C] //or any other combination
            
            we represent it in binary:
            for A: 001
            for B: 010
            for C: 100
            ==> 110     [1,3]
            
        */
        
        uint[] memory partition = new uint[](2);
        partition[0] = 1;
        partition[1] = 3;
        dai.approve(address(conditionalTokens), _amount);
        conditionalTokens.splitPosition(
            dai,    // this is caste our pointer automatically to an address !!
            bytes32(0),     // param collection ID !! with gnosis you can create several number of paired tokens
            conditionId,
            partition,      // array of outcome selection !!
            _amount
            );                 // this will convert your dai token to gnosis !!
            
            
        tokenBalance[_questionId][0] = _amount;
        tokenBalance[_questionId][1] = _amount;
    }
    
    function transferTokens(
            bytes32 _questionId,   // so that we can identify the bet !!
            uint _indexSet,      // outcome collection that you want !! i.e 0 or 1 from the above lines
            address _to,
            uint _amount
        ) external {
            
            bytes32 conditionId = conditionalTokens.getConditionId(
                oracle,
                _questionId,
                3
                );
            
            bytes32 collectionId = conditionalTokens.getCollectionId(
                bytes32(0),
                conditionId,
                _indexSet
                
                );
            
            uint positionId = conditionalTokens.getPositionId(
                dai,
                collectionId
                );
            
            require(msg.sender == admin, 'only admin');
            require(tokenBalance[_questionId][_indexSet] >= _amount, 'not enough token');
            conditionalTokens.safeTransferFrom(
                address(this),
                _to,    // need to impelment ERC1155 token receiverInterface
                positionId,     // uniquly identify a conditional Token
                _amount,
                ""
                );
        }
    
    
    // have implemented these function from ERC1155 function implementataion
    
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