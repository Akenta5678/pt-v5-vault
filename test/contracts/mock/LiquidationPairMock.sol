// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { IERC20 } from "openzeppelin/token/ERC20/IERC20.sol";
import { ERC20Mock } from "openzeppelin/mocks/ERC20Mock.sol";

import { ILiquidationSource } from "pt-v5-liquidator-interfaces/ILiquidationSource.sol";
import { MockLiquidatorLib } from "./MockLiquidatorLib.sol";

contract LiquidationPairMock {
  address internal _source;
  address internal _target;
  address internal _tokenIn;
  address internal _tokenOut;
  MockLiquidatorLib internal _liquidatorLib;

  constructor(address source_, address target_, address tokenIn_, address tokenOut_) {
    _source = source_;
    _target = target_;
    _tokenIn = tokenIn_;
    _tokenOut = tokenOut_;
    _liquidatorLib = new MockLiquidatorLib();
  }

  function _availableReserveOut() internal returns (uint256) {
    return ILiquidationSource(_source).liquidatableBalanceOf(_tokenOut);
  }

  function liquidate(
    address account,
    address /* tokenIn */,
    uint256 /* amountIn */,
    address tokenOut,
    uint256 amountOut
  ) external returns (bool) {
    ERC20Mock(tokenOut).transfer(account, amountOut);
    return true;
  }

  function computeExactAmountIn(uint256 _amountOut) external returns (uint256) {
    return _liquidatorLib.computeExactAmountIn(100, 50, _availableReserveOut(), _amountOut);
  }

  function swapExactAmountOut(
    address _account,
    uint256 _amountOut,
    uint256 _amountInMax
  ) external returns (uint256) {
    ILiquidationSource(_source).liquidate(_account, _tokenIn, _amountInMax, _tokenOut, _amountOut);

    return _amountInMax;
  }

  function target() external view returns (address) {
    return _target;
  }

  function tokenIn() external view returns (address) {
    return _tokenIn;
  }
}
