pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import 'uniswap-solidity/contracts/Uniswap.sol';

library SafeExchange {
    using SafeMath for uint256;

    modifier swaps(uint256 _value, IERC20 _token) {
        uint256 nextBalance = _token.balanceOf(address(this)).add(_value);
        _;
        require(
            _token.balanceOf(address(this)) >= nextBalance,
            "Balance validation failed after swap."
        );
    }

    function swapTokens(
        UniswapExchangeInterface _exchange,
        uint256 _outValue,
        uint256 _inValue,
        uint256 _ethValue,
        uint256 _deadline,
        IERC20 _outToken
    ) internal swaps(_outValue, _outToken) {
        _exchange.tokenToTokenSwapOutput(
            _outValue,
            _inValue,
            _ethValue,
            _deadline,
            address(_outToken)
        );
    }

    function swapEther(
        UniswapExchangeInterface _exchange,
        uint256 _outValue,
        uint256 _ethValue,
        uint256 _deadline,
        IERC20 _outToken
    ) internal swaps(_outValue, _outToken) {
        _exchange.ethToTokenSwapOutput.value(_ethValue)(_outValue, _deadline);
    }
}