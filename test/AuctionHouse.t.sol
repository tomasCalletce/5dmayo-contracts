// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {AuctionHouse} from "../src/AuctionHouse.sol";

contract AuctionHouseTest is Test {
    AuctionHouse public auctionHouse;

    function setUp() public {
        auctionHouse = new AuctionHouse({
        _minContributionPerTick : 10_000_000,
        _minTicksPerOrder : 5, 
        _expiration : block.timestamp + 4 days
      });
    }

    function testOffer() external {
        auctionHouse.offer({
            _amountToPayPerTick: 11_000_000,
            _orderSizeInTicks: 5,
            _receiver: 0x4635C9b762DD1aA7cb2ED5E69f60eD10cDB468F9,
            _expiration: block.timestamp + 1 days
        });

        uint256 listHead = auctionHouse.listHead();
    }
}
