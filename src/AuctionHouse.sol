//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IAuctionHouse } from "./interfaces/IAuctionHouse.sol";
import {StructuredLinkedList} from "./StructuredLinkedList.sol";

error InValidExpiration();
error InValidOrderSize();
error ExpiredOrder();
error InvalidAuctionId();
error InvalidAmountToPayPerTick();

contract AuctionHouse is IAuctionHouse {
  using StructuredLinkedList for StructuredLinkedList.List;

  uint256 public constant MAX_TICKS = 1000;

  uint public immutable minContributionPerTick;
  uint public immutable minTicksPerOrder;
  uint public immutable expiration;

  mapping(uint256 => Order) private orders;
  uint256 progressiveOrderId;

  StructuredLinkedList.List private list;
  
  constructor(
    uint256 _minContributionPerTick,
    uint256 _minTicksPerOrder,
    uint256 _expiration
  ){
    if (_expiration < block.timestamp) {
      revert InValidExpiration();
    }
    if (_minTicksPerOrder > MAX_TICKS) {
      revert InValidOrderSize();
    }

    minContributionPerTick = _minContributionPerTick;
    minTicksPerOrder = _minTicksPerOrder;
    expiration = _expiration;
  }

  function offer(
    uint256 _amountToPayPerTick,
    uint256 _orderSizeInTicks,
    uint256 _positionClaim,
    address _receiver,
    uint256 _expiration
  ) external returns (uint256) {
    if(_expiration > block.timestamp) {
      revert ExpiredOrder();
    }
    if(_orderSizeInTicks >= minTicksPerOrder) {
      revert InValidOrderSize();
    }
    if(_amountToPayPerTick >= minContributionPerTick) {
      revert InvalidAmountToPayPerTick();
    }

    uint256 resultingPosition = progressiveOrderId++;

    if(!list.listExists()){
      list.pushFront(resultingPosition);
      
      return resultingPosition;
    }

    uint256 current = list.popFront();


  }

}