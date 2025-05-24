// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MessageSender} from "../src/MessageSender.sol";
import {MessageReceiver} from "../src/MessageReceiver.sol";

/**
 * @title DeployTeleporterApp
 * @dev Script to deploy MessageSender and MessageReceiver contracts
 */
contract DeployTeleporterApp is Script {
    // Avalanche Mainnet C-Chain Teleporter address
    address public constant MAINNET_TELEPORTER =
        0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf;

    // Avalanche Fuji C-Chain Teleporter address
    address public constant FUJI_TELEPORTER =
        0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf;

    /**
     * @dev Deploy the contracts
     * @param teleporterAddress The address of the TeleporterMessenger contract
     */
    function deploy(address teleporterAddress) public {
        vm.startBroadcast();

        // Deploy MessageSender
        MessageSender sender = new MessageSender(teleporterAddress);
        console.log("MessageSender deployed at:", address(sender));

        // Deploy MessageReceiver
        MessageReceiver receiver = new MessageReceiver(teleporterAddress);
        console.log("MessageReceiver deployed at:", address(receiver));

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy to Avalanche Mainnet C-Chain
     */
    function deployMainnet() public {
        deploy(MAINNET_TELEPORTER);
    }

    /**
     * @dev Deploy to Avalanche Fuji C-Chain
     */
    function deployFuji() public {
        deploy(FUJI_TELEPORTER);
    }

    /**
     * @dev Default run function
     */
    function run() public {
        // If no specific environment is specified, deploy to Fuji by default
        deployFuji();
    }
}
