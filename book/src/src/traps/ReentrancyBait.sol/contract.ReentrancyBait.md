# ReentrancyBait
[Git Source](https://github.com/smallyunet/the-trapper/blob/0d9944dcdd16d135362e0768c3fa166bb70c92cf/src/traps/ReentrancyBait.sol)

**Title:**
ReentrancyBait

**Author:**
The-Trapper (Red Team)

TRAP EXPLANATION:
This contract exposes a classic reentrancy vulnerability.
THE BAIT:
- A `withdraw` function that sends ETH *before* updating the balance.
- This violates Checks-Effects-Interactions pattern.
THE TRAP:
- We use a secondary variable `_locked` or `gas` check that acts as a mutex
BUT it's hidden or implemented in a way that allows the FIRST reentry but fails deeply
nested ones, or traps the funds by updating a different state on reentry.
- Actually, a fun trap is: The reentrancy allows you to "double spend" but the
`transfer` uses a limited amount of gas that is enough for a wallet receive
but NOT enough for the complex fallback logic of the attacker.
- OR: We update a shadow balance in the reentrancy that results in 0 payout globally.


## State Variables
### balances

```solidity
mapping(address => uint256) public balances
```


### _shadowLock

```solidity
bool private _shadowLock
```


## Functions
### constructor


```solidity
constructor() payable;
```

### deposit


```solidity
function deposit() external payable;
```

### withdraw

The Vulnerable Function.
Attacker sees: call(value) BEFORE balances[msg.sender] = 0.


```solidity
function withdraw() external;
```

