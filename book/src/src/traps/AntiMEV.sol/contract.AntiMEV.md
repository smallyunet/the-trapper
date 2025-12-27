# AntiMEV
[Git Source](https://github.com/smallyunet/the-trapper/blob/31c92e1ccd8c6d51fd6e0efb1df8ddfcdca53e16/src/traps/AntiMEV.sol)

**Title:**
AntiMEV

**Author:**
The-Trapper (Red Team)

TRAP EXPLANATION:
This contract detects common simulation and MEV bot behaviors.
THE BAIT:
- A function `flashArb` that looks like a highly profitable arbitrage opportunity.
- It checks a visible "profit" condition that seems always true.
THE TRAP:
- It checks `tx.gasprice` or block properties to detect if it's being simulated
or if it's being included in a bundle with high gas price (frontrunning).
- If detected, it performs a "Silent Fail" or a "Gas Bomb".
- NOTE: `cobinbase` check is a classic way to detect if block builder is the destination,
but here we'll use a `gasleft()` check or similar heuristic.


## State Variables
### SECRET_THRESHOLD

```solidity
uint256 public constant SECRET_THRESHOLD = 50 gwei
```


## Functions
### receive


```solidity
receive() external payable;
```

### claimProfit

Looks like a free money button.
Attacker calls this thinking they can drain the contract.


```solidity
function claimProfit() external;
```

### _activateTrap


```solidity
function _activateTrap() private;
```

## Events
### ArbitrageOpportunity

```solidity
event ArbitrageOpportunity(uint256 expectedProfit);
```

### Gotcha

```solidity
event Gotcha(address indexed bot);
```

