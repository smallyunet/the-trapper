# TheLabyrinth
[Git Source](https://github.com/smallyunet/the-trapper/blob/13b8db8b187d1f1af200624016fe5e6186a0ab55/src/traps/TheLabyrinth.sol)

**Title:**
The Labyrinth

A progressive CTF challenge.

The goal is to successfully call `solve` and retrieve the bounty.
There are 3 gates to pass.


## State Variables
### secret

```solidity
bytes32 private secret
```


### locked

```solidity
bool private locked
```


## Functions
### constructor


```solidity
constructor() payable;
```

### solve

Attempt to solve the labyrinth.


```solidity
function solve(bytes32 _guess) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_guess`|`bytes32`|The magic word to bypass Gate 2.|


### receive


```solidity
receive() external payable;
```

## Events
### ChallengeSolved

```solidity
event ChallengeSolved(address winner, uint256 bounty);
```

### TrapTriggered

```solidity
event TrapTriggered(address victim, string trapName);
```

