// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {UserProofHub} from "../src/UserProofHub.sol";
import {UserProofReceiver} from "../src/UserProofReceiver.sol";

/**
 * @title DeployTeleporterApp
 * @dev Script to deploy UserProofHub and UserProofReceiver contracts
 */
contract DeployTeleporterApp is Script {
    /**
     * @dev Deploy only UserProofHub (for source chain)
     */
    function deploySenderOnly() public {
        vm.startBroadcast();

        UserProofHub sender = new UserProofHub();
        console.log("UserProofHub deployed at:", address(sender));

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy only UserProofReceiver (for destination chain)
     */
    function deployReceiverOnly() public {
        vm.startBroadcast();

        UserProofReceiver receiver = new UserProofReceiver();
        console.log("UserProofReceiver deployed at:", address(receiver));

        vm.stopBroadcast();
    }
}
