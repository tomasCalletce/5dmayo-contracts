// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "./interfaces/ITeleporterMessenger.sol";

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {IAuctionHouse} from "./interfaces/IAuctionHouse.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

error Unauthorized();

contract FRcertificate is ERC721 {
    using SafeERC20 for IERC20;

    struct Position {
        uint256 amountToPayPerTick;
        uint256 orderSizeInTicks;
    }

    mapping(uint256 => Position) public positions;

    /*//////////////////////////////////////////////////////////////
                                 CONSTANTS
    //////////////////////////////////////////////////////////////*/

    ITeleporterMessenger public immutable teleporterMessenger =
        ITeleporterMessenger(0x50A46AA7b2eCBe2B1AbB7df865B9A87f5eed8635);

    /*//////////////////////////////////////////////////////////////
                                 STORAGE
    //////////////////////////////////////////////////////////////*/

    IERC20 settlementAddress;

    address public auctionHouse;

    uint256 settlementDate;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _auctionHouse, address _settlementAddress) ERC721("FRcertificate", "FRC") {
        settlementAddress = IERC20(_settlementAddress);
        auctionHouse = _auctionHouse;
        settlementDate = _settlementAddress;
    }

    /*//////////////////////////////////////////////////////////////
                            FRC LOGIC
    //////////////////////////////////////////////////////////////*/

    function receiveTeleporterMessage(bytes32 originChainID, address originSenderAddress, bytes calldata message)
        external
    {
        if (msg.sender != address(teleporterMessenger) || originSenderAddress != auctionHouse) {
            revert Unauthorized();
        }

        (IAuctionHouse.Order memory order, uint256 orderId) = abi.decode(message, (IAuctionHouse.Order, uint256));

        // settlementAddress.safeTransferFrom(
        //     order.receiver, address(this), order.amountToPayPerTick * order.orderSizeInTicks
        // );

        _mint(order.receiver, orderId);

        Position memory newPosition =
            Position({amountToPayPerTick: order.amountToPayPerTick, orderSizeInTicks: order.orderSizeInTicks});

        positions[orderId] = newPosition;
    }
}
