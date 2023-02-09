// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20{

    constructor(string memory _name, string memory _symbol, address _mintTo, uint _mintAmount) ERC20(_name, _symbol) {
        _mint(_mintTo, _mintAmount);
    }

}