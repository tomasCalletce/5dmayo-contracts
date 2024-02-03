//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {StructuredLinkedList} from "../StructuredLinkedList.sol";

interface IAuctionHouse {
    struct Order {
        uint256 amountToPayPerTick;
        uint256 orderSizeInTicks;
        address receiver;
    }

    function offer(uint256 _amountToPayPerTick, uint256 _orderSizeInTicks, address _receiver, uint256 _expiration)
        external
        returns (uint256);
}
