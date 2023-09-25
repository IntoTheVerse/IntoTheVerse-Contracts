// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapRouter {
    ISwapRouter public immutable uniswapRouter;
    IUniswapV2Router02 public immutable ubeswapRouter;
    IUniswapV3Factory public immutable uniswapFactory;

    uint24[3] public feeTiers = [500, 3000, 10000]; // 0.05%, 0.3%, and 1% respectively

    constructor(
        address _uniswapRouter,
        address _ubeswapRouter,
        address _uniswapFactory
    ) {
        uniswapRouter = ISwapRouter(_uniswapRouter);
        ubeswapRouter = IUniswapV2Router02(_ubeswapRouter);
        uniswapFactory = IUniswapV3Factory(_uniswapFactory);
    }

    function calculateUniswapV3FeeTier(
        address tokenA,
        address tokenB
    ) public view returns (uint24) {
        for (uint i = 0; i < feeTiers.length; i++) {
            address poolAddress = uniswapFactory.getPool(
                tokenA,
                tokenB,
                feeTiers[i]
            );
            if (poolAddress != address(0)) {
                // Pool exists for this fee tier
                IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
                uint24 poolFee = pool.fee();

                return poolFee;
            }
        }
        revert("No pool exists for the given token pair");
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
        uint256 amountOutMin
    ) external {
        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "Transfer failed"
        );
        require(
            IERC20(tokenIn).approve(address(uniswapRouter), amountIn),
            "Approval failed"
        );

        uint24 feeTiers = calculateUniswapV3FeeTier(tokenIn, tokenOut);
        // Define the params for the V3 swap
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: feeTiers,
                recipient: msg.sender,
                deadline: block.timestamp + 300,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0 // No price limit
            });

        uniswapRouter.exactInputSingle(params);
    }
}
