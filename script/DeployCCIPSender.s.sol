// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/CCIPSender.sol";

contract DeployCCIPSender is Script {
    function run() external {
        vm.startBroadcast();

        address router = 0xF694E193200268f9a4868e4Aa017A0118C9a8177; // Fuji Router
        address link = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846; // Fuji LINK token

        new CCIPSender(router, link);

        vm.stopBroadcast();
    }
}
