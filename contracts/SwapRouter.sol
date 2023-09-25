// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapRouter {
    ISwapRouter public immutable uniswapRouter;
    IUniswapV2Router02 public immutable ubeswapRouter;

    constructor(address _uniswapRouter, address _ubeswapRouter) {
        uniswapRouter = ISwapRouter(_uniswapRouter);
        ubeswapRouter = IUniswapV2Router02(_ubeswapRouter);
    }

    function swapOnV2(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) external {
        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "Transfer failed"
        );
        require(
            IERC20(tokenIn).approve(address(ubeswapRouter), amountIn),
            "Approval failed"
        );

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        ubeswapRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 300
        );
    }

    function swapOnV3(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 fee
    ) external {
        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "Transfer failed"
        );
        require(
            IERC20(tokenIn).approve(address(uniswapRouter), amountIn),
            "Approval failed"
        );

        // Define the params for the V3 swap
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: msg.sender,
                deadline: block.timestamp + 300,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0 // No price limit
            });

        uniswapRouter.exactInputSingle(params);
    }
}
