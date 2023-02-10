// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./utils/mathUtils.sol";
import "hardhat/console.sol";


contract CPAMM {
    using MathUtils for uint256;

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0;
    uint public reserve1;

    uint public totalSupply;
    uint public shares;
    mapping(address => uint) public balanceOf;

    error TokenInInvalid();
    error AmountInZero();
    error LiquidityCanLeadToPriceChange();
    error CannotMintZeroShares();
    error AmountTokensZeroAfterBurningShare();

    event LiquidityAdded(uint shares, uint amount0, uint amount1, address liqiudityProvider);
    event LiquidityRemoved(uint shares, uint token0Released, uint token1Released, address liquidityProvider);

    constructor(address _token0, address _token1){
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _reserve0, uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }


    function swap(address _tokenIn, uint _amountIn) external returns(uint amountOut){
        if(_tokenIn != address(token0) && _tokenIn != address(token1)){
            revert TokenInInvalid();
        }
        if(_amountIn <= 0){
            revert AmountInZero();
        }

        // accept tokenIn
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint reserveIn, uint reserveOut) = isToken0 ?
            (token0, token1, reserve0, reserve1) :
            (token1, token0, reserve1, reserve0);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // Calculate token out (include fees of 0.03%)
        // ydx / (x + dx) = dy
        uint amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = reserveOut * amountInWithFee/ (reserveIn + amountInWithFee);


        tokenOut.transfer(msg.sender, amountOut);
        // send tokenOut to msg.sender

        // update reserves
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }


    function addLiquidity(uint _amount0, uint _amount1) external {
        // take token0 and token 1
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        // mint shares

        if(reserve0 > 0 || reserve1 > 0){
            if(reserve0 * _amount1 != reserve1 * _amount0){
                revert LiquidityCanLeadToPriceChange();
            }
            // minting shares
            // f(x, y) = sqrt(xy)
            // s = dy/y * T = dx/x * T
        }

        if(totalSupply == 0){
            // shares = _sqrt(_amount0 * _amount1);
            shares = (_amount0 * _amount1)._sqrt();
        } else {
            shares = (_amount0 * totalSupply/reserve0)._min(_amount1 * totalSupply/reserve1);
        }
        if(shares <= 0){
            revert CannotMintZeroShares();
        }
        // console.log(shares);
        _mint(msg.sender, shares);
        // update reserves
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
        emit LiquidityAdded(shares, _amount0, _amount1, msg.sender);

    }

    function removeLiquidity(uint _shares) external returns(uint _amount0, uint _amount1) {
        // amount0, amount1 to withdraw
        // dx = s / T * x
        // dy = s / T * y
        // burn shares and 
        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));

        _amount0 = (_shares * bal0)/ totalSupply;
        _amount1 = (_shares * bal1)/ totalSupply;
        if(_amount0 == 0 ||_amount1 == 0){
            revert AmountTokensZeroAfterBurningShare();
        }

        _burn(msg.sender, _shares);
        _update(bal0 - _amount0, bal1 - _amount1);
        token0.transfer(msg.sender, _amount0);
        token1.transfer(msg.sender, _amount1);
        // LiquidityRemoved(uint shares, uint token0Released, uint token1Released, address liquidityProvider)
        emit LiquidityRemoved(_shares, _amount0, _amount1, msg.sender);
    }

}