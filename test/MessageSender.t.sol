// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MessageSender} from "../src/MessageSender.sol";

contract MessageSenderTest is Test {
    // Fuji C-chain Teleporter address
    address constant FUJI_TELEPORTER =
        0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf;

    // Our deployed MessageSender contract
    MessageSender public sender;

    // Test accounts
    address public deployer = makeAddr("deployer");
    address public user = makeAddr("user");

    // Fuji C-chain ID (hex representation)
    bytes32 public fujiCChainID =
        0x7fc93d85c6d62c5b2ac0b519c87010ea5294012d1e407030d6c8e05e7cd4727d;

    function setUp() public {
        // Fork Fuji C-chain
        uint256 fujiCChainFork = vm.createFork(
            "https://api.avax-test.network/ext/bc/C/rpc"
        );
        vm.selectFork(fujiCChainFork);

        // Fund the deployer account
        vm.deal(deployer, 10 ether);

        // Deploy MessageSender contract as deployer
        vm.startPrank(deployer);
        sender = new MessageSender(FUJI_TELEPORTER);
        vm.stopPrank();

        // Verify the contract was deployed correctly
        assertEq(address(sender.teleporterMessenger()), FUJI_TELEPORTER);

        console.log("MessageSender deployed at:", address(sender));
    }

    function testSendMessage() public {
        // Destination address (could be on another chain)
        address destinationAddress = makeAddr("receiver");

        // Set the user as the sender
        vm.startPrank(user);

        // Mock a destination blockchain ID (could be another subnet)
        bytes32 destinationBlockchainID = bytes32(uint256(137750));

        // Send a message without fees
        bytes32 messageID = sender.sendMessage(
            destinationBlockchainID,
            destinationAddress,
            "Hello from Fuji C-chain!"
        );

        // Verify the message ID is not zero
        assertTrue(messageID != bytes32(0), "Message ID should not be zero");

        vm.stopPrank();
    }
}
