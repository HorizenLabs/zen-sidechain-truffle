//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DemoToken is ERC20 {
    constructor() ERC20("Demo Token", "DEMO"){
        // mint 100 tokens to the sender on deployment
        _mint(msg.sender, 100);
    }
}
