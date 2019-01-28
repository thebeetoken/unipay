pragma solidity ^0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import 'uniswap-solidity/contracts/Uniswap.sol';
import "./safe/SafeERC20.sol";
import "./safe/SafeExchange.sol";

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
