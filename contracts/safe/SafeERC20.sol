pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library SafeERC20 {
    using SafeMath for uint256;

    function transferTokens(
      IERC20 _token,
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
      IERC20 _token,
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