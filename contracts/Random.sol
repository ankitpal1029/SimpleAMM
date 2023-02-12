// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Random {
    event ConstructorCalled(address caller);
    event RandomFunctionCalled(address caller);
    constructor() {
        emit ConstructorCalled(msg.sender);
    }

    function randomFunction() external returns(uint) {
        emit RandomFunctionCalled(msg.sender);
        return 69;
    }

    function returnFunction() external pure returns(uint) {
        return 69;
    }
}