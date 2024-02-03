//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { StructuredLinkedList } from "../StructuredLinkedList.sol";

interface IAuctionHouse {

  struct Order {
    uint256 amountToPayPerTick;
    uint256 orderSizeInTicks;
    address receiver;
  }


}