// Created by Yug Khandelwal for ETHMumbai 2026
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MumbaiFund is ReentrancyGuard {
    address public owner;
    uint256 public goal = 1 ether;
    uint256 public deadline;
    mapping(address => uint256) public contributions;
    uint256 public totalRaised;

    event Contributed(address indexed contributor, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);
    event Refunded(address indexed contributor, uint256 amount);

    constructor(uint256 _duration) {
        owner = msg.sender;
        deadline = block.timestamp + _duration;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign ended");
        require(msg.value > 0, "Contribution must be greater than 0");
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
        emit Contributed(msg.sender, msg.value);
    }

    function withdraw() external nonReentrant {
        require(msg.sender == owner, "Only owner");
        require(block.timestamp >= deadline, "Campaign ongoing");
        require(totalRaised >= goal, "Goal not reached");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
        emit Withdrawn(owner, balance);
    }

    function getRefund() external nonReentrant {
        require(block.timestamp >= deadline, "Campaign ongoing");
        require(totalRaised < goal, "Goal reached");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contribution");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Refunded(msg.sender, amount);
    }
}
