// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Scientific Fund with External Oracle Validation
/// @author Proyecto Final Web3
/// @notice Extends the funding escrow with an external validation layer before releasing funds.
// 1) Interfaz que define el contrato externo con el que este contrato interactúa.
//    La validación del hito se delega a un oracle ajeno a este contrato.
interface IScientificOracle {
    function validateMilestone(address project, uint256 milestoneId, string memory ipfsHash, uint256 amount)
        external
        view
        returns (bool);
}

contract ScientificFundOracle is Ownable, ReentrancyGuard {
    struct Milestone {
        string title;
        string ipfsHash;
        uint256 amount;
        bool released;
        bool oracleApproved;
        uint256 votesFor;
        uint256 votesAgainst;
    }

    uint256 public totalRaised;
    uint256 public totalReleased;
    uint256 public milestoneCount;
    address public oracle;

    address[] public auditors;
    mapping(address => bool) public isAuditor;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => Milestone) public milestones;
    mapping(address => uint256) public contributions;

    event Contribution(address indexed donor, uint256 amount, uint256 totalRaised_);
    event MilestoneCreated(uint256 indexed milestoneId, string title, string ipfsHash, uint256 amount);
    event VoteCast(uint256 indexed milestoneId, address indexed auditor, bool support);
    event OracleUpdated(address indexed oracle);
    event OracleApproval(uint256 indexed milestoneId, bool approved);
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
    error OracleRejected();
    error InvalidOracle();
    error TransferFailed();

    // 2) Constructor: recibe la dirección del contrato oracle externo.
    //    Ese address se guarda en storage y será usado más adelante para invocarlo.
    //    Ejemplo de uso correcto:
    //    ScientificFundOracle fund = new ScientificFundOracle(
    //        0x1111111111111111111111111111111111111111,
    //        [0x222..., 0x333..., 0x444...],
    //        0x5555555555555555555555555555555555555555
    //    );
    //    Si alguna dirección es 0x000... o no llega definida, la transacción hace revert.
    constructor(address _projectOwner, address[] memory _auditors, address _oracle) Ownable(_projectOwner) {
        if (_projectOwner == address(0)) revert ZeroAddress();
        if (_auditors.length == 0) revert ZeroAddress();
        if (_oracle == address(0)) revert InvalidOracle();

        oracle = _oracle;
        emit OracleUpdated(_oracle);

        for (uint256 i = 0; i < _auditors.length; i++) {
            address auditor = _auditors[i];
            if (auditor == address(0)) revert ZeroAddress();
            if (!isAuditor[auditor]) {
                isAuditor[auditor] = true;
                auditors.push(auditor);
            }
        }
    }

    /// @notice Contribute ETH to the escrow that supports scientific milestones.
    function contribute() external payable nonReentrant {
        if (msg.value == 0) revert InvalidAmount();

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        emit Contribution(msg.sender, msg.value, totalRaised);
    }

    /// @notice Register a scientific milestone with its evidential reference.
    /// @param _title Milestone title.
    /// @param _ipfsHash Hash or CID representing the milestone evidence.
    /// @param _amount ETH amount reserved for the milestone.
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
            oracleApproved: false,
            votesFor: 0,
            votesAgainst: 0
        });
        milestoneCount++;

        emit MilestoneCreated(milestoneId, _title, _ipfsHash, _amount);
    }

    /// @notice Vote on the milestone approval.
    /// @param _milestoneId Milestone identifier.
    /// @param _support Approval or rejection vote.
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

    /// @notice Ask the external oracle to validate the milestone evidence.
    /// @param _milestoneId Milestone to validate.
    // 3) Llamada inter-contratos: este contrato invoca el oracle externo.
    //    El resultado booleano decide si el hito queda validado o rechazado.
    function validateMilestone(uint256 _milestoneId) external {
        if (_milestoneId >= milestoneCount) revert MilestoneNotFound();
        if (milestones[_milestoneId].released) revert MilestoneAlreadyReleased();
        if (oracle == address(0)) revert InvalidOracle();

        bool approved = IScientificOracle(oracle)
            .validateMilestone(
                owner(), _milestoneId, milestones[_milestoneId].ipfsHash, milestones[_milestoneId].amount
            );

        milestones[_milestoneId].oracleApproved = approved;
        emit OracleApproval(_milestoneId, approved);
    }

    /// @notice Release funds after oracle and auditor approval.
    /// @param _milestoneId Milestone being released.
    // 4) Una vez que el oracle y los auditores aprueban, se libera el pago.
    //    Esta parte usa la validación previa para evitar transferencias no autorizadas.
    function releaseMilestone(uint256 _milestoneId) external onlyOwner nonReentrant {
        if (_milestoneId >= milestoneCount) revert MilestoneNotFound();

        Milestone storage milestone = milestones[_milestoneId];
        if (milestone.released) revert MilestoneAlreadyReleased();
        if (!milestone.oracleApproved) revert OracleRejected();

        uint256 approvalVotes = milestone.votesFor;
        uint256 rejectionVotes = milestone.votesAgainst;
        uint256 totalAuditors = auditors.length;

        if (approvalVotes <= rejectionVotes || approvalVotes <= (totalAuditors / 2)) {
            revert NoApproval();
        }

        if (address(this).balance < totalReleased + milestone.amount) revert InvalidAmount();

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
