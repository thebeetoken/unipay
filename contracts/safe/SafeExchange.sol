pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import 'uniswap-solidity/contracts/Uniswap.sol';

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

    function swapEther(
        UniswapExchangeInterface _exchange,
        uint256 _outValue,
        uint256 _ethValue,
        uint256 _deadline,
        ERC20 _outToken
    ) internal {
        uint256 nextBalance = _outToken.balanceOf(address(this)).add(_outValue);
        _exchange.ethToTokenSwapOutput.value(_ethValue)(_outValue, _deadline);
        require(
            _outToken.balanceOf(address(this)) >= nextBalance,
            "Balance validation failed after swap."
        );
    }
}