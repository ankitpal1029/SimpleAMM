// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/interfaces/IERC20.sol";


contract StakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    address public owner;

    uint public duration;
    uint public finishAt;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;

    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    function setRewardsDuration(uint _duration) external onlyOwner{
        require(block.timestamp > finishAt, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint _amount) external {
        if(block.timestamp > finishAt) {
            rewardRate = _amount/ duration;
        } else {
            uint remainingRewards = rewardRate * (finishAt - block.timestamp);
            rewardRate = (remainingRewards + _amount) / duration;
        }
        require(rewardRate > 0, "reward rate is 0");
        require(rewardRate * duration <= rewardsToken.balanceOf(address(this)), "reward balace < reward");

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }


    function stake(uint _amount) external {}

    function withdraw(uint _amount) external {}

    function earned(uint _account) external view returns(uint) {

    }

    function getReward() external {}



}