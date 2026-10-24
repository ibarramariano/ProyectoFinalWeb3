// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ScientificFund} from "../contracts/ScientificFund.sol";

contract ScientificFundTest is Test {
    ScientificFund public fund;

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

        deal(projectOwner, 10 ether);
        deal(donor, 10 ether);

        fund = new ScientificFund(projectOwner, auditors);
    }

    function test_contribute_and_release_milestone() public {
        vm.prank(donor);
        fund.contribute{value: 5 ether}();

        assertEq(fund.totalRaised(), 5 ether);

        vm.prank(projectOwner);
        fund.createMilestone("Fase 1: prototipo", "QmHash001", 2 ether);

        vm.prank(auditor1);
        fund.voteMilestone(0, true);

        vm.prank(auditor2);
        fund.voteMilestone(0, true);

        vm.prank(auditor3);
        fund.voteMilestone(0, false);

        uint256 projectOwnerBalanceBefore = projectOwner.balance;

        vm.prank(projectOwner);
        fund.releaseMilestone(0);

        assertEq(fund.totalReleased(), 2 ether);
        assertEq(projectOwner.balance, projectOwnerBalanceBefore + 2 ether);
        assertTrue(fund.isMilestoneReleased(0));
    }

    function test_release_requires_majority_approval() public {
        vm.prank(donor);
        fund.contribute{value: 5 ether}();

        vm.prank(projectOwner);
        fund.createMilestone("Fase 2: validacion", "QmHash002", 1 ether);

        vm.prank(auditor1);
        fund.voteMilestone(0, true);

        vm.prank(auditor2);
        fund.voteMilestone(0, false);

        vm.expectRevert();
        vm.prank(projectOwner);
        fund.releaseMilestone(0);
    }
}
