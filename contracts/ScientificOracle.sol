// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 1) Contrato oracle propio del proyecto.
//    Este contrato implementa la misma interfaz que usa ScientificFundOracle,
//    por lo que puede ser desplegado en una red pública y utilizado como
//    validación externa del hito.
contract ScientificOracle {
    // 2) La validación acepta el proyecto, el ID del hito, el hash del IPFS y la cantidad.
    //    Para este MVP, la verificación se realiza de forma determinista y simple:
    //    si la dirección del proyecto es válida, el IPFS no está vacío y el monto es > 0,
    //    el hito se considera válido.
    function validateMilestone(address project, uint256 milestoneId, string memory ipfsHash, uint256 amount)
        external
        view
        returns (bool)
    {
        if (project == address(0)) return false;
        if (bytes(ipfsHash).length == 0) return false;
        if (amount == 0) return false;
        if (milestoneId == 0 && bytes(ipfsHash).length > 0) return true;
        return true;
    }
}
