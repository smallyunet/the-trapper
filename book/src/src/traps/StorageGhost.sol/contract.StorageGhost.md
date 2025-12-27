# StorageGhost
[Git Source](https://github.com/smallyunet/the-trapper/blob/31c92e1ccd8c6d51fd6e0efb1df8ddfcdca53e16/src/traps/StorageGhost.sol)

**Title:**
StorageGhost

**Author:**
The-Trapper (Red Team)

TRAP EXPLANATION:
This contract appears to be a standard Proxy/Implementation pattern where
the owner can update the implementation.
THE BAIT:
- A `delegatecall` to an implementation address that seems to allow overwriting the `owner`.
- The attacker sees `owner` at slot 0 and `implementation` at slot 1 in the main contract.
- The attacker provides a malicious implementation that writes their address to slot 0.
THE TRAP:
- We use unstructured storage or a subtle inline assembly shift.
- In this specific example, the `owner` is NOT at slot 0 despite the declaration order
suggesting it might be alignable.
- Actually, we define a different storage layout or use a collision that writes to a
"trap" slot which locks the contract or burns gas, while the real processing happens elsewhere.
For this simple v1:
The `owner` variable is actually shadowed or the layout is messed up by inheritance
or we use EIP-1967 style slots but mislead the attacker about which one is active.
Let's make it simpler but effective:
The "Bait" contract uses `delegatecall` to `lib`. `lib` has `owner` at slot 0.
The "Ghost" contract has a hidden variable at slot 0 that triggers a LOCK when modified.


## State Variables
### trapSlot

```solidity
uint256 private trapSlot
```


### _OWNER_SLOT

```solidity
bytes32 internal constant _OWNER_SLOT = keccak256("storage.ghost.owner")
```


## Functions
### onlyOwner


```solidity
modifier onlyOwner() ;
```

### constructor


```solidity
constructor() ;
```

### _getOwner


```solidity
function _getOwner() internal view returns (address owner);
```

### _setOwner


```solidity
function _setOwner(address newOwner) internal;
```

### execute


```solidity
function execute(address target, bytes calldata data) external payable;
```

### withdraw


```solidity
function withdraw() external onlyOwner;
```

### receive


```solidity
receive() external payable;
```

## Events
### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
```

