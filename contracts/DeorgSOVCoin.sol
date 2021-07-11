//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DeorgSOV is ERC20 {
    constructor() public ERC20("DeorgSOV", "DSOV") {
    }
}

