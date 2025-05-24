// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MessageSender} from "../src/MessageSender.sol";
import {MessageReceiver} from "../src/MessageReceiver.sol";

/**
 * @title DeployTeleporterApp
 * @dev Script to deploy MessageSender and MessageReceiver contracts
 */
contract DeployTeleporterApp is Script {
    /**
     * @dev Deploy only MessageSender (for source chain)
     */
    function deploySenderOnly() public {
        vm.startBroadcast();

        MessageSender sender = new MessageSender();
        console.log("MessageSender deployed at:", address(sender));

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy only MessageReceiver (for destination chain)
     */
    function deployReceiverOnly() public {
        vm.startBroadcast();

        MessageReceiver receiver = new MessageReceiver();
        console.log("MessageReceiver deployed at:", address(receiver));

        vm.stopBroadcast();
    }
}
