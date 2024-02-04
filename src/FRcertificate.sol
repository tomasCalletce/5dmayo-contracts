// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {IAuctionHouse} from "./interfaces/IAuctionHouse.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

error Unauthorized();

contract FRcertificate is ERC721 {
    using SafeERC20 for IERC20;

    IERC20 settlementAddress;

    address public auctionHouse;

    constructor(address _auctionHouse, address _settlementAddress) ERC721("FRcertificate", "FRC") {
        auctionHouse = _auctionHouse;
        settlementAddress = IERC20(_settlementAddress);
    }

    function receiveTeleporterMessage(bytes32 originChainID, address originSenderAddress, bytes calldata message)
        external
    {
        (IAuctionHouse.Order memory order, uint256 orderId) = abi.decode(message, (IAuctionHouse.Order, uint256));

        // settlementAddress.safeTransferFrom(
        //     order.receiver, address(this), order.amountToPayPerTick * order.orderSizeInTicks
        // );

        _mint(order.receiver, orderId);
    }
}
