# HoneypotToken
[Git Source](https://github.com/smallyunet/the-trapper/blob/31c92e1ccd8c6d51fd6e0efb1df8ddfcdca53e16/src/traps/HoneypotToken.sol)

**Inherits:**
ERC20, Ownable

**Title:**
HoneypotToken

Looks like a standard meme token but traps sellers.

Uses a hidden whitelist mechanism to prevent non-owners from selling (transferring to pair).


## State Variables
### _isPairs

```solidity
mapping(address => bool) private _isPairs
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

### _beforeTokenTransfer

Hidden "Anti-Bot" (actually Anti-Sell) Logic


```solidity
function _beforeTokenTransfer(
    address from,
    address to,
    uint256 /* amount */
)
    internal
    virtual
    override;
```

