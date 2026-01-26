# HotPotato
[Git Source](https://github.com/smallyunet/the-trapper/blob/6942e4ea803492c5b787cbd84cd1b0695f0d3075/src/traps/HotPotato.sol)

**Inherits:**
ERC20, Ownable

**Title:**
HotPotato

A cursed token that decays over time.

Implements a negative rebase (decay) and a trap on selling.


## State Variables
### _lastInteractionBlock
Mapping to store the last block number a user interacted with the token.


```solidity
mapping(address => uint256) private _lastInteractionBlock
```


### DECAY_RATE_BPS
The decay rate in basis points per block (e.g., 100 = 1%).


```solidity
uint256 public constant DECAY_RATE_BPS = 100
```


## Functions
### constructor


```solidity
constructor() ;
```

### name


```solidity
function name() public view virtual override returns (string memory);
```

### symbol


```solidity
function symbol() public view virtual override returns (string memory);
```

### balanceOf

Returns the balance of `owner` after applying decay.

This is a view function that calculates the decayed balance on the fly.


```solidity
function balanceOf(address owner) public view override returns (uint256);
```

### _beforeTokenTransfer

Update states before transfer and check for trap conditions.


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override;
```

