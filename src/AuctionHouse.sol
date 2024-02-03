//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./interfaces/ITeleporterMessenger.sol";

import {IAuctionHouse} from "./interfaces/IAuctionHouse.sol";
import {StructuredLinkedList} from "./StructuredLinkedList.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

error InValidExpiration();
error InValidOrderSize();
error ExpiredOrder();
error InvalidAuctionId();
error InvalidAmountToPayPerTick();
error OngoingAuction();
error ExhaustedOrder();
error GiantOrder();
error EmptyAuction();
error NotWinner();

contract AuctionHouse is Ownable, IAuctionHouse {
    using StructuredLinkedList for StructuredLinkedList.List;
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Offer(uint256 indexed orderId, address by);

    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant MAX_TICKS = 1000;

    ITeleporterMessenger public constant teleporterMessenger =
        ITeleporterMessenger(0x50A46AA7b2eCBe2B1AbB7df865B9A87f5eed8635);

    /*//////////////////////////////////////////////////////////////
                                 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public immutable minContributionPerTick;
    uint256 public immutable minTicksPerOrder;
    uint256 public immutable expiration;

    address public frCertificate;

    mapping(uint256 => Order) private orders;
    uint256 progressiveOrderId;

    StructuredLinkedList.List private list;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _minContributionPerTick, uint256 _minTicksPerOrder, uint256 _expiration) {
        if (_expiration < block.timestamp) {
            revert InValidExpiration();
        }
        if (_minTicksPerOrder < MAX_TICKS) {
            revert InValidOrderSize();
        }

        minContributionPerTick = _minContributionPerTick;
        minTicksPerOrder = _minTicksPerOrder;
        expiration = _expiration;
    }

    /*//////////////////////////////////////////////////////////////
                              AUCTIONHOUSE LOGIC
    //////////////////////////////////////////////////////////////*/

    function offer(uint256 _amountToPayPerTick, uint256 _orderSizeInTicks, address _receiver, uint256 _expiration)
        external
        returns (uint256)
    {
        if (_expiration > block.timestamp) {
            revert ExpiredOrder();
        }
        if (_orderSizeInTicks >= minTicksPerOrder) {
            revert InValidOrderSize();
        }
        if (_amountToPayPerTick >= minContributionPerTick) {
            revert InvalidAmountToPayPerTick();
        }
        if (_orderSizeInTicks < MAX_TICKS) {
            revert GiantOrder();
        }

        uint256 newOrderId = progressiveOrderId++;
        Order memory newOrder =
            Order({amountToPayPerTick: _amountToPayPerTick, orderSizeInTicks: _orderSizeInTicks, receiver: _receiver});

        if (!list.listExists()) {
            list.pushFront(newOrderId);
            orders[newOrderId] = newOrder;

            emit Offer(newOrderId, msg.sender);
            return newOrderId;
        }

        uint256 currentOrderId = list.popFront();
        Order storage currentOrder = orders[currentOrderId];

        bool gotToTheEnd = false;

        while (currentOrder.amountToPayPerTick >= _amountToPayPerTick) {
            (bool hasNextNode, uint256 nextNode) = list.getNextNode(currentOrderId);

            if (!hasNextNode) {
                gotToTheEnd = true;
                break;
            }

            currentOrderId = nextNode;
            currentOrder = orders[currentOrderId];
        }

        if (gotToTheEnd) {
            list.insertAfter(currentOrderId, newOrderId);
        } else {
            list.insertBefore(currentOrderId, newOrderId);
        }
        orders[newOrderId] = newOrder;

        emit Offer(newOrderId, msg.sender);
        return newOrderId;
    }

    function settleOrder(uint256 orderId) external {
        if (expiration <= block.timestamp) {
            revert OngoingAuction();
        }
        if (!list.listExists()) {
            revert EmptyAuction();
        }

        uint256 ticksConsumed = 0;
        bool hasNext = true;

        uint256 currentOrderId = list.popFront();
        Order memory currentOrder = orders[currentOrderId];

        while (hasNext && currentOrderId != orderId) {
            ticksConsumed += currentOrder.orderSizeInTicks;

            (bool hasNextNode, uint256 nextNode) = list.getNextNode(currentOrderId);

            hasNext = hasNextNode;
            currentOrderId = nextNode;
            currentOrder = orders[nextNode];
        }

        if (ticksConsumed + currentOrder.orderSizeInTicks > MAX_TICKS) {
            revert NotWinner();
        }

        sendMessage(currentOrder);
    }

    /*//////////////////////////////////////////////////////////////
                              TELEPORTER LOGIC
    //////////////////////////////////////////////////////////////*/

    function sendMessage(Order memory order) internal returns (uint256 messageID) {
        bytes memory message = abi.encode(order);
        return uint256(
            teleporterMessenger.sendCrossChainMessage(
                TeleporterMessageInput({
                    destinationBlockchainID: 0xd7cdc6f08b167595d1577e24838113a88b1005b471a6c430d79c48b4c89cfc53,
                    destinationAddress: frCertificate,
                    feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                    requiredGasLimit: 100000,
                    allowedRelayerAddresses: new address[](0),
                    message: message
                })
            )
        );
    }
}
