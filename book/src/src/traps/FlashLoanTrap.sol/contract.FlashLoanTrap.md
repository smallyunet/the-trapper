# FlashLoanTrap
[Git Source](https://github.com/smallyunet/the-trapper/blob/b83caee862a973052f95e2b1731f2e7d476f25ad/src/traps/FlashLoanTrap.sol)

**Title:**
FlashLoanTrap

**Author:**
The-Trapper (Red Team)

TRAP EXPLANATION:
This contract mimics a flash loan provider with seemingly exploitable callback.
THE BAIT:
- A `flashLoan` function that sends ETH and expects it back with a fee.
- The callback structure looks vulnerable to "not paying back" or manipulation.
- Attacker thinks they can receive the loan, use it profitably, and not return it.
THE TRAP:
- Uses balance snapshot checks before and after the callback.
- Detects flash loan arbitrage patterns via same-block balance changes.
- If detected, reverts the entire transaction AFTER the attacker has spent gas on complex operations.
- Additionally tracks if the caller is a contract executing within the same transaction.
PUNISHMENT:
- Reverts after expensive callback execution, wasting attacker's gas.
- Emits trap event for monitoring.


## State Variables
### FEE_BPS

```solidity
uint256 public constant FEE_BPS = 10
```


### _lastInteractionBlock

```solidity
mapping(address => uint256) private _lastInteractionBlock
```


### _interactionCount

```solidity
mapping(address => uint256) private _interactionCount
```


## Functions
### receive


```solidity
receive() external payable;
```

### flashLoan

The Bait: Flash loan function that looks exploitable


```solidity
function flashLoan(uint256 amount, address target, bytes calldata data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Amount to borrow|
|`target`|`address`|Contract to callback|
|`data`|`bytes`|Callback data|


### getAvailableLiquidity

Check available liquidity (BAIT - shows funds available)


```solidity
function getAvailableLiquidity() external view returns (uint256);
```

### _activateTrap

Trap activation - burns gas


```solidity
function _activateTrap() private pure;
```

### _isContract

Check if address is a contract


```solidity
function _isContract(address account) private view returns (bool);
```

## Events
### FlashLoanExecuted

```solidity
event FlashLoanExecuted(address indexed borrower, uint256 amount);
```

### TrapTriggered

```solidity
event TrapTriggered(address indexed attacker, string reason);
```

