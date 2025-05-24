// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MessageReceiver} from "../src/MessageReceiver.sol";

/**
 * @title DeployMessageReceiver
 * @dev Script to deploy MessageReceiver contract
 */
contract DeployMessageReceiver is Script {
    /**
     * @dev Deploy MessageReceiver contract
     * @param teleporterAddress The address of the TeleporterMessenger contract
     * @return receiver The deployed MessageReceiver contract
     */
    function deployReceiver(
        address teleporterAddress
    ) public returns (MessageReceiver) {
        MessageReceiver receiver = new MessageReceiver(teleporterAddress);
        console.log("MessageReceiver deployed at:", address(receiver));
        return receiver;
    }
}
