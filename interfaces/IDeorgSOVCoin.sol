//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;




interface IDeorgSOVCoin {
      function mintDeorgReward(address[] memory beneficiaries) external returns(bool);
}

