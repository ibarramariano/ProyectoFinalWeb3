// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ScientificFundOracle, IScientificOracle} from "../contracts/ScientificFundOracle.sol";

contract MockOracle is IScientificOracle {
    bool public approved;

    function setApproved(bool _approved) external {
        approved = _approved;
    }

    function validateMilestone(address, uint256, string memory, uint256) external view override returns (bool) {
        return approved;
    }
}

contract ScientificFundOracleTest is Test {
    ScientificFundOracle public fund;
    MockOracle public oracle;

    address public projectOwner = address(0xA11CE);
    address public auditor1 = address(0xB11CE);
    address public auditor2 = address(0xC11CE);
    address public auditor3 = address(0xD11CE);
    address public donor = address(0xE11CE);

    function setUp() public {
        address[] memory auditors = new address[](3);
        auditors[0] = auditor1;
        auditors[1] = auditor2;
        auditors[2] = auditor3;

        oracle = new MockOracle();
        oracle.setApproved(true);

        deal(projectOwner, 10 ether);
        deal(donor, 10 ether);

        fund = new ScientificFundOracle(projectOwner, auditors, address(oracle));
    }

    function test_release_requires_oracle_approval() public {
        vm.prank(donor);
        fund.contribute{value: 5 ether}();

        vm.prank(projectOwner);
        fund.createMilestone("Fase 1: validacion", "QmHashOracle", 2 ether);

        vm.prank(auditor1);
        fund.voteMilestone(0, true);

        vm.prank(auditor2);
        fund.voteMilestone(0, true);

        vm.prank(auditor3);
        fund.voteMilestone(0, true);

        vm.prank(projectOwner);
        fund.validateMilestone(0);

        vm.prank(projectOwner);
        fund.releaseMilestone(0);

        assertTrue(fund.isMilestoneReleased(0));
    }

    function test_release_reverts_when_oracle_rejects() public {
        oracle.setApproved(false);

        vm.prank(donor);
        fund.contribute{value: 5 ether}();

        vm.prank(projectOwner);
        fund.createMilestone("Fase 2: revision", "QmHashOracleReject", 2 ether);

        vm.prank(auditor1);
        fund.voteMilestone(0, true);

        vm.prank(auditor2);
        fund.voteMilestone(0, true);

        vm.prank(auditor3);
        fund.voteMilestone(0, true);

        vm.prank(projectOwner);
        fund.validateMilestone(0);

        vm.expectRevert();
        vm.prank(projectOwner);
        fund.releaseMilestone(0);
    }
}
