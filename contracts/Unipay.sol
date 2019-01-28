pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import 'uniswap-solidity/contracts/Uniswap.sol';

library SafeERC20 {
    using SafeMath for uint256;

    function transferTokens(
      ERC20 _token,
      address _from,
      address _to,
      uint256 _value
    ) internal {
        uint256 oldBalance = _token.balanceOf(_to);
        require(
            _token.transferFrom(_from, _to, _value),
            "Failed to transfer tokens."
        );
        require(
            _token.balanceOf(_to) >= oldBalance.add(_value),
            "Balance validation failed after transfer."
        );
    }

    function approveTokens(
      ERC20 _token,
      address _spender,
      uint256 _value
    ) internal {
        uint256 nextAllowance =
          _token.allowance(address(this), _spender).add(_value);
        require(
            _token.approve(_spender, nextAllowance),
            "Failed to approve exchange withdrawal of tokens."
        );
        require(
            _token.allowance(address(this), _spender) >= nextAllowance,
            "Failed to validate token approval."
        );
    }
}

library SafeExchange {
    using SafeMath for uint256;

    function swapTokens(
        UniswapExchangeInterface _exchange,
        uint256 _outValue,
        uint256 _inValue,
        uint256 _ethValue,
        uint256 _deadline,
        ERC20 _outToken
    ) internal {
        uint256 nextBalance = _outToken.balanceOf(address(this)).add(_outValue);
        _exchange.tokenToTokenSwapOutput(
            _outValue,
            _inValue,
            _ethValue,
            _deadline,
            address(_outToken)
        );
        require(
            _outToken.balanceOf(address(this)) >= nextBalance,
            "Balance validation failed after swap."
        );
    }
}

contract Unipay {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using SafeExchange for UniswapExchangeInterface;

    UniswapFactoryInterface factory;
    ERC20 outToken;
    address recipient;

    constructor(address _factory, address _recipient, address _token) public {
        factory = UniswapFactoryInterface(_factory);
        outToken = ERC20(_token);
        recipient = _recipient;
    }

    function price(
        address _token,
        uint256 _value
    ) public view returns (uint256, uint256, UniswapExchangeInterface) {
        UniswapExchangeInterface inExchange =
          UniswapExchangeInterface(factory.getExchange(_token));
        UniswapExchangeInterface outExchange =
          UniswapExchangeInterface(factory.getExchange(address(outToken)));
        uint256 etherCost = outExchange.getEthToTokenOutputPrice(_value);
        uint256 tokenCost = inExchange.getTokenToEthOutputPrice(etherCost);
        return (tokenCost, etherCost, inExchange);
    }

    function collect(
        address _from,
        address _token,
        uint256 _value,
        uint256 _deadline
    ) public {
        (
            uint256 tokenCost,
            uint256 etherCost,
            UniswapExchangeInterface exchange
        ) = price(_token, _value);

        ERC20(_token).transferTokens(_from, address(this), tokenCost);
        ERC20(_token).approveTokens(address(exchange), tokenCost);
        exchange.swapTokens(_value, tokenCost, etherCost, _deadline, outToken);
        outToken.approveTokens(recipient, _value);
    }
}
