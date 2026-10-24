// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ScientificFund} from "../contracts/ScientificFund.sol";

contract ScientificFundScript is Script {
    function run() external returns (ScientificFund) {
        address projectOwner = vm.envAddress("PROJECT_OWNER");
        address auditor1 = vm.envAddress("AUDITOR_1");
        address auditor2 = vm.envAddress("AUDITOR_2");
        address auditor3 = vm.envAddress("AUDITOR_3");

        address[] memory auditors = new address[](3);
        auditors[0] = auditor1;
        auditors[1] = auditor2;
        auditors[2] = auditor3;

        vm.startBroadcast();
        ScientificFund fund = new ScientificFund(projectOwner, auditors);
        vm.stopBroadcast();

        return fund;
    }
}
