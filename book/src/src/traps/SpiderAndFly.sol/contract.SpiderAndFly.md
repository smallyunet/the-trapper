# SpiderAndFly
[Git Source](https://github.com/smallyunet/the-trapper/blob/6942e4ea803492c5b787cbd84cd1b0695f0d3075/src/traps/SpiderAndFly.sol)

**Inherits:**
ERC721, Ownable

**Title:**
SpiderAndFly

A gamified MEV honeypot that mints a "Caught Fly" NFT to suspicious callers.

Educational trap: EOAs see a revert; MEV-like callers get a badge (and no profit).


## State Variables
### GASPRICE_THRESHOLD

```solidity
uint256 public constant GASPRICE_THRESHOLD = 30 gwei
```


### nextId

```solidity
uint256 public nextId = 1
```


## Functions
### constructor


```solidity
constructor() payable;
```

### receive


```solidity
receive() external payable;
```

### name


```solidity
function name() public pure override returns (string memory);
```

### symbol


```solidity
function symbol() public pure override returns (string memory);
```

### tokenURI


```solidity
function tokenURI(uint256 id) public view override returns (string memory);
```

### claimProfit

The bait: looks like a profitable claim.

For EOAs under normal gas, reverts. For MEV-like callers, mints a badge and returns.


```solidity
function claimProfit() external;
```

### withdraw

Withdraw accumulated bait (owner only).


```solidity
function withdraw(address payable to, uint256 amount) external onlyOwner;
```

### _isSuspiciousCaller


```solidity
function _isSuspiciousCaller() internal view returns (bool suspicious, string memory reason);
```

### _burnSomeGas


```solidity
function _burnSomeGas() private pure;
```

### _toString


```solidity
function _toString(uint256 value) private pure returns (string memory str);
```

## Events
### Opportunity

```solidity
event Opportunity(uint256 expectedProfitWei);
```

### FlyCaught

```solidity
event FlyCaught(address indexed fly, uint256 indexed tokenId, string reason);
```

