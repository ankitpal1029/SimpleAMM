// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


library MathUtils {
    // babylonian method
    function _sqrt(uint y) internal pure returns(uint z) {
        if(y > 3){
            z = y;
            uint x = y/2 + 1;
            while(x < z){
                z = x;
                x = (y/x + x) /2;
            }
        } else if(y != 0){
            z = 1;
        }
    }

    function _min(uint x, uint y) internal pure returns (uint){
        return x <= y ? x: y;
    }

}