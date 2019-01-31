# Unipay

[Uniswap](https://uniswap.io)-enabled payments. Allow payment to be made with
any [ERC-20](https://theethereum.wiki/w/index.php/ERC20_Token_Standard) token
while receiving payment in your token of choice using pooled liquidity.

Unipay accepts tokens and ether, converts these to the desired token, and
makes `approve` calls to allow the payment recipient to transfer those tokens
from the contract.

Authored by [Vic Woeltjen](https://github.com/woeltjen) for
[The Bee Token](https://github.com/thebeetoken) 🐝

## Install

    npm i

## Compile

    npm run compile

Compiled contracts will be written to the `build` directory as 
[Truffle](https://truffleframework.com)
[build artifacts](https://truffleframework.com/docs/truffle/getting-started/compiling-contracts#build-artifacts).

## Usage

A Unipay contract is deployed with the following configuration parameters:

* `address factory`: The address of the Uniswap factory contract to use to
  access swappable liquidity.
* `address recipient`: The address of the recipient for payments made via
  this contract.
* `address token`: The address of the token used to represent the payment,
  as received by the recipient.

Unipay exposes the following methods:

* `price(address token, uint256 value)`: Get the cost, in units of the
  identified `token`, of making a payment of the specified `value` in
  this contract's configured payment token.
* `price(uint256 value)`: Get the cost, in wei, of making a payment of the
  specified `value` in this contract's configured payment token.
* `collect(address from, address token, uint256 value, uint256 deadline)`:
  Collect payment in the specified `token` from the `from` address and
  swap for `value` of the configured payment token, with a transaction
  `deadline` specified in seconds since the start of 1970. The `from`
  address must previously `approve` this contract to transfer a sufficient
  amount to complete the swap; user code should call `price` to determine an
  appropriate approval amount.
* `pay(uint256 value, uint256 deadline) payable`: Deliver payment as ether
  and swap for `value` of the configured payment token, with a transaction
  `deadline` specified in seconds since the start of 1970. Any excess ether
  sent with this call will be returned to the caller.
