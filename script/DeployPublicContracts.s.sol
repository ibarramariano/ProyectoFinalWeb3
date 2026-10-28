// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ScientificFundOracle} from "../contracts/ScientificFundOracle.sol";
import {ScientificOracle} from "../contracts/ScientificOracle.sol";

// 1) Script orientado a despliegue real en red pública EVM.
//    Requiere un RPC público y una private key del deployer.
contract DeployPublicContracts is Script {
    function run() external returns (ScientificOracle oracle, ScientificFundOracle fund) {
        // 2) El owner del proyecto y los auditores deben venir del entorno.
        //    En una red real, estos valores se configuran con la wallet del cliente.
        //    Ejemplo:
        //    $env:PROJECT_OWNER = "0x000000000000000000000000000000000"
        //    $env:AUDITOR_1 = "0x3000000000000000000000000000ce0"
        //    $env:AUDITOR_2 = "0xb0000000000000000000000000000000000009a17"
        //    $env:AUDITOR_3 = "0xe00000000000000000000000000000000000055a1f05"
        address projectOwner = vm.envAddress("PROJECT_OWNER");
        address auditor1 = vm.envAddress("AUDITOR_1");
        address auditor2 = vm.envAddress("AUDITOR_2");
        address auditor3 = vm.envAddress("AUDITOR_3");

        address[] memory auditors = new address[](3);
        auditors[0] = auditor1;
        auditors[1] = auditor2;
        auditors[2] = auditor3;

        vm.startBroadcast();

        // 3) Primero se despliega el oracle propio del proyecto.
        oracle = new ScientificOracle();

        // 4) Luego se despliega el contrato principal apuntando al oracle.
        fund = new ScientificFundOracle(projectOwner, auditors, address(oracle));

        vm.stopBroadcast();
    }
}
