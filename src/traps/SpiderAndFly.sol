// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "solady/tokens/ERC721.sol";
import {Ownable} from "solady/auth/Ownable.sol";

/// @title SpiderAndFly
/// @notice A gamified MEV honeypot that mints a "Caught Fly" NFT to suspicious callers.
/// @dev Educational trap: EOAs see a revert; MEV-like callers get a badge (and no profit).
contract SpiderAndFly is ERC721, Ownable {
    uint256 public constant GASPRICE_THRESHOLD = 30 gwei;

    uint256 public nextId = 1;

    event Opportunity(uint256 expectedProfitWei);
    event FlyCaught(address indexed fly, uint256 indexed tokenId, string reason);

    constructor() payable {
        _initializeOwner(msg.sender);
    }

    receive() external payable {}

    function name() public pure override returns (string memory) {
        return "Caught Fly";
    }

    function symbol() public pure override returns (string memory) {
        return "FLY";
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        // Revert if token does not exist.
        ownerOf(id);

        return string.concat(
            "data:application/json;utf8,{",
            '"name":"Caught Fly #',
            _toString(id),
            '",',
            '"description":"A badge minted by The Trapper: Spider & Fly. If you got this, you looked like an MEV bot.",',
            '"attributes":[{"trait_type":"collection","value":"the-trapper"},{"trait_type":"trap","value":"spider-and-fly"}]',
            "}"
        );
    }

    /// @notice The bait: looks like a profitable claim.
    /// @dev For EOAs under normal gas, reverts. For MEV-like callers, mints a badge and returns.
    function claimProfit() external {
        require(address(this).balance > 0, "No funds");

        emit Opportunity(1 wei);

        (bool suspicious, string memory reason) = _isSuspiciousCaller();
        if (!suspicious) {
            revert("Conditions changed");
        }

        uint256 tokenId = nextId++;
        _mint(msg.sender, tokenId);

        // Burn a bit of gas (bounded) to make simulation / bundle spam more annoying.
        _burnSomeGas();

        emit FlyCaught(msg.sender, tokenId, reason);
    }

    /// @notice Withdraw accumulated bait (owner only).
    function withdraw(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "bad to");
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "withdraw failed");
    }

    function _isSuspiciousCaller() internal view returns (bool suspicious, string memory reason) {
        if (tx.gasprice > GASPRICE_THRESHOLD) {
            return (true, "high gas price");
        }
        if (msg.sender != tx.origin) {
            return (true, "tx.origin mismatch");
        }
        if (msg.sender.code.length > 0) {
            return (true, "contract caller");
        }
        return (false, "");
    }

    function _burnSomeGas() private pure {
        unchecked {
            uint256 acc;
            for (uint256 i = 0; i < 5000; ++i) {
                acc ^= (i * 7919);
            }
            // Prevent the compiler from optimizing the loop away.
            if (acc == type(uint256).max) {
                revert("unreachable");
            }
        }
    }

    function _toString(uint256 value) private pure returns (string memory str) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        str = string(buffer);
    }
}
