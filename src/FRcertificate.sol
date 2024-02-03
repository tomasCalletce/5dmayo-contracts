// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";

contract FRcertificate is ERC721  {
  constructor() ERC721("MyToken", "MTK") {}

}
