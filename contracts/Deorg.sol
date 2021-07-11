//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";


contract Deorg {

    struct DeorgBounty{
       uint deadlineBlockNumber;
       uint reward; 
       address [] beneficiaries; // known address(es), presumably belonging to miners
       address creator;
    }

    DeorgBounty[] public deorgBounties; 
    uint constant CLAIM_WINDOW_BLOCKS = 40320; // ~1 week

    function createBounty(uint deadlineBlockNumber, bytes32 expectedTargetBlockHash, uint targetBlockNumber, address[] memory beneficiaries ) public payable returns(bool) {
        require(beneficiaries.length > 0, "NEED_BENEFICIARIES");
        require(deadlineBlockNumber > block.number, "deadlineBlockNumber_SHOULD_BE_IN_FUTURE");

        bytes32 actualTargetBlockhash = blockhash(targetBlockNumber);
        require(actualTargetBlockhash == expectedTargetBlockHash, "CAN'T_REPLAY_THIS_ONE_NICE_TRY_THO");

        DeorgBounty memory newBounty = DeorgBounty({
            deadlineBlockNumber: deadlineBlockNumber,
            reward: msg.value,
            beneficiaries: beneficiaries,
            creator: msg.sender
        });

        deorgBounties.push(newBounty);
        return true;
    }   

    function claimBounty(uint bountyIndex) public  ensureBountyExists(bountyIndex) returns(bool)  {
        DeorgBounty memory deorgBounty = deorgBounties[bountyIndex];
        require(block.number > deorgBounty.deadlineBlockNumber, "TOO_SOON_BRO");

        uint rewardPerBenficiary = deorgBounty.reward / deorgBounty.beneficiaries.length;
        for (uint256 i = 0; i < deorgBounty.beneficiaries.length; i++) {
            payable(deorgBounty.beneficiaries[i]).transfer(rewardPerBenficiary);
        }
        removeBounty(bountyIndex);
        return true;
    }

    function redeemUnclaimedBounty(uint bountyIndex) public ensureBountyExists(bountyIndex) returns(bool){
        DeorgBounty memory deorgBounty = deorgBounties[bountyIndex];
        require(block.number > deorgBounty.deadlineBlockNumber + CLAIM_WINDOW_BLOCKS, "TOO_SOON_BRO");

        payable(deorgBounty.creator).transfer(deorgBounty.reward);

        removeBounty(bountyIndex);

        return true;
    }

    function removeBounty(uint bountyIndex) internal returns(bool){
        delete deorgBounties[bountyIndex];
        return true;
    }

    modifier ensureBountyExists (uint bountyIndex) {
        DeorgBounty memory deorgBounty = deorgBounties[bountyIndex];
        require(deorgBounty.creator != address(0), "BOUNTY_NOT_FOUND");
        _;
    }  

}
