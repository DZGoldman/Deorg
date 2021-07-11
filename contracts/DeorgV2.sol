//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Deorg.sol";
import "../interfaces/IDeorgSOVCoin.sol";

contract DeorgV2 is Deorg {
    address deorgSOVAddress;
    constructor(address _deorgSOVAddress) {
        deorgSOVAddress = _deorgSOVAddress;
    }

    function claimBounty(uint bountyIndex) public override  ensureBountyExists(bountyIndex) returns(bool)  {
        DeorgBounty memory deorgBounty = deorgBounties[bountyIndex];
        require(block.number > deorgBounty.deadlineBlockNumber, "TOO_SOON_BRO");

        uint rewardPerBenficiary = deorgBounty.reward / deorgBounty.beneficiaries.length;
        for (uint256 i = 0; i < deorgBounty.beneficiaries.length; i++) {
            payable(deorgBounty.beneficiaries[i]).transfer(rewardPerBenficiary);
        }
        removeBounty(bountyIndex);
        
        IDeorgSOVCoin(deorgSOVAddress).mintDeorgReward(deorgBounty.beneficiaries);

        return true;
    }



}