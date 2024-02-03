// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";

contract FRcertificate is ERC721 {
    constructor() ERC721("FRcertificate", "FRC") {}

    // function receiveTeleporterMessage(bytes32 originChainID, address originSenderAddress, bytes calldata message)
    //     external
    // {
    //     if (msg.sender != address(teleporterMessenger) || teleporterSenderAddress != originSenderAddress) {
    //         revert Unauthorized();
    //     }
    //     _originChainID = originChainID;
    //     _originSenderAddress = originSenderAddress;

    //     (OperationType operationType, uint256 num1, uint256 num2) =
    //         abi.decode(message, (OperationType, uint256, uint256));
    //     if (operationType == OperationType.Sum) {
    //         ultraCalculator.sumTwoNumbers(num1, num2);
    //     } else if (operationType == OperationType.Subtract) {
    //         ultraCalculator.subtractTwoNumbers(num1, num2);
    //     } else if (operationType == OperationType.Multiply) {
    //         ultraCalculator.multiplyTwoNumbers(num1, num2);
    //     } else if (operationType == OperationType.Divide) {
    //         ultraCalculator.divideTwoNumbers(num1, num2);
    //     } else {
    //         revert OperationTypeNotFound(uint8(operationType));
    //     }
    // }
}
