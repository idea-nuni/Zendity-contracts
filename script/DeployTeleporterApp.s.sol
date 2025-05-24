// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MessageSender} from "../src/MessageSender.sol";
import {MessageReceiver} from "../src/MessageReceiver.sol";
import {DeployMessageReceiver} from "./DeployMessageReceiver.s.sol";

/**
 * @title DeployTeleporterApp
 * @dev Script to deploy MessageSender and MessageReceiver contracts
 */
contract DeployTeleporterApp is Script {
    // Avalanche Fuji C-Chain Teleporter address
    address public constant FUJI_TELEPORTER =
        0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf;

    /**
     * @dev Deploy to Avalanche Fuji C-Chain
     */
    function deployFuji() public {
        deploy(FUJI_TELEPORTER);
    }

    /**
     * @dev Deploy only MessageSender (for source chain)
     * @param teleporterAddress The address of the TeleporterMessenger contract
     */
    function deploySenderOnly(address teleporterAddress) public {
        vm.startBroadcast();

        MessageSender sender = new MessageSender(teleporterAddress);
        console.log("MessageSender deployed at:", address(sender));

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy only MessageReceiver (for destination chain)
     * @param teleporterAddress The address of the TeleporterMessenger contract
     */
    function deployReceiverOnly(address teleporterAddress) public {
        vm.startBroadcast();

        DeployMessageReceiver receiverDeployer = new DeployMessageReceiver();
        MessageReceiver receiver = receiverDeployer.deployReceiver(
            teleporterAddress
        );

        vm.stopBroadcast();
    }

    /**
     * @dev Send a cross-chain message (run this on the source chain)
     * @param senderAddress The deployed MessageSender contract address
     * @param destinationBlockchainID The destination blockchain ID
     * @param receiverAddress The MessageReceiver contract address on destination chain
     */
    function sendCrossChainMessage(
        address senderAddress,
        bytes32 destinationBlockchainID,
        address receiverAddress
    ) public {
        vm.startBroadcast();

        MessageSender sender = MessageSender(senderAddress);
        bytes32 messageID = sender.sendMessage(
            destinationBlockchainID,
            receiverAddress,
            "Hello from another chain!"
        );

        console.log(
            "Cross-chain message sent with ID:",
            vm.toString(messageID)
        );
        console.log(
            "Destination blockchain ID:",
            vm.toString(destinationBlockchainID)
        );
        console.log("Destination address:", receiverAddress);

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy the contracts and send a test message (single chain)
     * @param teleporterAddress The address of the TeleporterMessenger contract
     */
    function deploy(address teleporterAddress) public {
        vm.startBroadcast();

        // Step 1: Deploy MessageSender first
        MessageSender sender = new MessageSender(teleporterAddress);
        console.log("MessageSender deployed at:", address(sender));

        // Step 2: Deploy MessageReceiver using the separate script
        DeployMessageReceiver receiverDeployer = new DeployMessageReceiver();
        MessageReceiver receiver = receiverDeployer.deployReceiver(
            teleporterAddress
        );

        // Step 3: Send a test message
        sendTestMessage(sender, address(receiver));

        vm.stopBroadcast();
    }

    /**
     * @dev Send a test message using the deployed MessageSender
     * @param sender The deployed MessageSender contract
     * @param destinationAddress The destination address (receiver contract)
     */
    function sendTestMessage(
        MessageSender sender,
        address destinationAddress
    ) internal {
        // Mock a destination blockchain ID (could be another subnet)
        //"98qnjenm7MBd8G2cPZoRvZrgJC33JGSAAKghsQ6eojbLCeRNp"
        bytes32 destinationBlockchainID = 0x1278d1be4b987e847be3465940eb5066c4604a7fbd6e086900823597d81af4c1;

        // Send a message without fees
        bytes32 messageID = sender.sendMessage(
            destinationBlockchainID,
            destinationAddress,
            "Hello from Fuji C-chain!"
        );

        console.log("Test message sent with ID:", vm.toString(messageID));
        console.log(
            "Destination blockchain ID:",
            vm.toString(destinationBlockchainID)
        );
        console.log("Destination address:", destinationAddress);
    }

    /**
     * @dev Default run function
     */
    function run() public {
        // If no specific environment is specified, deploy to Fuji by default
        deployFuji();
    }
}
