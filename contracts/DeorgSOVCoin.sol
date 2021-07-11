//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;



import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DeorgSOV is ERC20 {
    address deorgAddress;
    uint256 constant supplyCap  = 21000000000000000000000000;
    constructor() public ERC20("DeorgSOV", "DSOV") {}

    function init (address _deorgAddress) external returns(bool) {
        require(deorgAddress != address(0), "ALREADY_INITED");
        deorgAddress = _deorgAddress;
        return true;
    }

    function mintDeorgReward(address[] memory beneficiaries) public onlyFromDeorg returns(bool)  {
        require(beneficiaries.length > 0, "NEED_BENEFICIARIES");
        uint rewardPerBenficiary = (supplyCap - totalSupply()) * 1/(10 * beneficiaries.length);
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            _mint(beneficiaries[i], rewardPerBenficiary);
        }

        require(totalSupply() <= supplyCap, "Supply cap superceded somehow; must prevent at all costs, sorry");

        return true;
    }   

    modifier onlyFromDeorg(){
        require(msg.sender == deorgAddress, "NOT_FROM_DEORG");
        _;
    }
}

