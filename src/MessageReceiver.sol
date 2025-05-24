// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ITeleporterReceiver} from "@teleporter/ITeleporterReceiver.sol";

/**
 * @title MessageReceiver
 * @dev A contract that implements ITeleporterReceiver to receive messages from other chains
 */
contract MessageReceiver is ITeleporterReceiver {
    // Store the most recent message received
    struct ReceivedMessage {
        bytes32 sourceBlockchainID;
        address sourceSenderAddress;
        string message;
        uint256 timestamp;
    }

    // The address of the TeleporterMessenger contract (same on all chains)
    address public immutable teleporterMessenger;

    // Map message IDs to received messages
    mapping(bytes32 => ReceivedMessage) public receivedMessages;

    // Keep track of all message IDs for iteration
    bytes32[] public messageIDs;

    // Event emitted when a message is received
    event MessageReceived(
        bytes32 indexed sourceBlockchainID,
        address indexed sourceSenderAddress,
        string message,
        uint256 timestamp
    );

    /**
     * @dev Constructor sets the TeleporterMessenger address
     * @param _teleporterMessenger The address of the TeleporterMessenger contract
     */
    constructor(address _teleporterMessenger) {
        require(
            _teleporterMessenger != address(0),
            "Invalid teleporter address"
        );
        teleporterMessenger = _teleporterMessenger;
    }

    /**
     * @dev Implements the ITeleporterReceiver interface
     * This function is called by the TeleporterMessenger contract when a message is received
     * @param sourceBlockchainID The blockchain ID where the message originated
     * @param originSenderAddress The address that sent the message on the source chain
     * @param message The message payload
     */
    function receiveTeleporterMessage(
        bytes32 sourceBlockchainID,
        address originSenderAddress,
        bytes calldata message
    ) external override {
        // Only allow the TeleporterMessenger contract to call this function
        require(msg.sender == teleporterMessenger, "Unauthorized sender");

        // Decode the message
        string memory messageContent = abi.decode(message, (string));

        // Create a unique ID for this message based on blockchain ID, sender, and timestamp
        bytes32 messageID = keccak256(
            abi.encodePacked(
                sourceBlockchainID,
                originSenderAddress,
                messageContent,
                block.timestamp
            )
        );

        // Store the message
        receivedMessages[messageID] = ReceivedMessage({
            sourceBlockchainID: sourceBlockchainID,
            sourceSenderAddress: originSenderAddress,
            message: messageContent,
            timestamp: block.timestamp
        });

        // Add the message ID to the array for iteration
        messageIDs.push(messageID);

        // Emit event
        emit MessageReceived(
            sourceBlockchainID,
            originSenderAddress,
            messageContent,
            block.timestamp
        );
    }

    /**
     * @dev Get the total number of messages received
     * @return The number of messages received
     */
    function getMessageCount() external view returns (uint256) {
        return messageIDs.length;
    }

    /**
     * @dev Get a message by its index
     * @param index The index of the message in the messageIDs array
     * @return messageID The unique ID of the message
     * @return sourceBlockchainID The blockchain ID where the message originated
     * @return sourceSenderAddress The address that sent the message on the source chain
     * @return message The message content
     * @return timestamp The time the message was received
     */
    function getMessageByIndex(
        uint256 index
    )
        external
        view
        returns (
            bytes32 messageID,
            bytes32 sourceBlockchainID,
            address sourceSenderAddress,
            string memory message,
            uint256 timestamp
        )
    {
        require(index < messageIDs.length, "Index out of bounds");

        messageID = messageIDs[index];
        ReceivedMessage storage receivedMessage = receivedMessages[messageID];

        return (
            messageID,
            receivedMessage.sourceBlockchainID,
            receivedMessage.sourceSenderAddress,
            receivedMessage.message,
            receivedMessage.timestamp
        );
    }
}
