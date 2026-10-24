// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Scientific Fund Escrow
/// @author Proyecto Final Web3
/// @notice Smart contract that manages scientific funding, auditor voting, and milestone release.
/// @dev The project owner can create milestones; auditors vote on each milestone and approved funds are released from escrow.
contract ScientificFund is Ownable, ReentrancyGuard {
    struct Milestone {
        string title;
        string ipfsHash;
        uint256 amount;
        bool released;
        uint256 votesFor;
        uint256 votesAgainst;
    }

    uint256 public totalRaised;
    uint256 public totalReleased;
    uint256 public milestoneCount;

    address[] public auditors;
    mapping(address => bool) public isAuditor;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => Milestone) public milestones;
    mapping(address => uint256) public contributions;

    event Contribution(address indexed donor, uint256 amount, uint256 totalRaised_);
    event MilestoneCreated(uint256 indexed milestoneId, string title, string ipfsHash, uint256 amount);
    event VoteCast(uint256 indexed milestoneId, address indexed auditor, bool support);
    event MilestoneReleased(uint256 indexed milestoneId, uint256 amount, address recipient);

    error ZeroAddress();
    error EmptyTitle();
    error EmptyIpfsHash();
    error InvalidAmount();
    error NotAuditor();
    error AlreadyVoted();
    error MilestoneNotFound();
    error MilestoneAlreadyReleased();
    error NoApproval();
    error InsufficientBalance();
    error TransferFailed();

    constructor(address _projectOwner, address[] memory _auditors) Ownable(_projectOwner) {
        if (_projectOwner == address(0)) revert ZeroAddress();
        if (_auditors.length == 0) revert ZeroAddress();

        for (uint256 i = 0; i < _auditors.length; i++) {
            address auditor = _auditors[i];
            if (auditor == address(0)) revert ZeroAddress();
            if (!isAuditor[auditor]) {
                isAuditor[auditor] = true;
                auditors.push(auditor);
            }
        }
    }

    /// @notice Contribute ETH to the scientific funding escrow.
    /// @dev The contribution increases the total raised amount and is stored by donor.
    function contribute() external payable nonReentrant {
        if (msg.value == 0) revert InvalidAmount();

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        emit Contribution(msg.sender, msg.value, totalRaised);
    }

    /// @notice Create a funding milestone for the scientific project.
    /// @param _title Descriptive name of the milestone.
    /// @param _ipfsHash Immutable reference to evidence or progress documentation.
    /// @param _amount ETH amount assigned to this milestone.
    function createMilestone(string memory _title, string memory _ipfsHash, uint256 _amount) external onlyOwner {
        if (bytes(_title).length == 0) revert EmptyTitle();
        if (bytes(_ipfsHash).length == 0) revert EmptyIpfsHash();
        if (_amount == 0) revert InvalidAmount();

        uint256 milestoneId = milestoneCount;
        milestones[milestoneId] = Milestone({
            title: _title,
            ipfsHash: _ipfsHash,
            amount: _amount,
            released: false,
            votesFor: 0,
            votesAgainst: 0
        });
        milestoneCount++;

        emit MilestoneCreated(milestoneId, _title, _ipfsHash, _amount);
    }

    /// @notice Vote whether a milestone should be approved or rejected.
    /// @param _milestoneId Identifier of the milestone to evaluate.
    /// @param _support True for approval and false for rejection.
    function voteMilestone(uint256 _milestoneId, bool _support) external {
        if (!isAuditor[msg.sender]) revert NotAuditor();
        if (_milestoneId >= milestoneCount) revert MilestoneNotFound();
        if (hasVoted[_milestoneId][msg.sender]) revert AlreadyVoted();
        if (milestones[_milestoneId].released) revert MilestoneAlreadyReleased();

        hasVoted[_milestoneId][msg.sender] = true;

        if (_support) {
            milestones[_milestoneId].votesFor++;
        } else {
            milestones[_milestoneId].votesAgainst++;
        }

        emit VoteCast(_milestoneId, msg.sender, _support);
    }

    /// @notice Release milestone funds if a majority approves the milestone.
    /// @param _milestoneId Identifier of the milestone to release.
    function releaseMilestone(uint256 _milestoneId) external onlyOwner nonReentrant {
        if (_milestoneId >= milestoneCount) revert MilestoneNotFound();

        Milestone storage milestone = milestones[_milestoneId];
        if (milestone.released) revert MilestoneAlreadyReleased();
        if (milestone.amount == 0) revert InvalidAmount();

        uint256 approvalVotes = milestone.votesFor;
        uint256 rejectionVotes = milestone.votesAgainst;
        uint256 totalAuditors = auditors.length;

        if (approvalVotes <= rejectionVotes || approvalVotes <= (totalAuditors / 2)) {
            revert NoApproval();
        }

        if (address(this).balance < totalReleased + milestone.amount) revert InsufficientBalance();

        milestone.released = true;
        totalReleased += milestone.amount;

        (bool success, ) = payable(owner()).call{value: milestone.amount}("");
        if (!success) revert TransferFailed();

        emit MilestoneReleased(_milestoneId, milestone.amount, owner());
    }

    function isMilestoneReleased(uint256 _milestoneId) external view returns (bool) {
        if (_milestoneId >= milestoneCount) revert MilestoneNotFound();
        return milestones[_milestoneId].released;
    }
}
