// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ITeleporterMessenger, TeleporterMessageInput, TeleporterFeeInfo} from "@teleporter/ITeleporterMessenger.sol";
import {IERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MessageSender
 * @dev A contract that sends messages to other chains using Teleporter
 */
contract MessageSender {
    using SafeERC20 for IERC20;

    // The address of the TeleporterMessenger contract (same on all chains)
    address public immutable teleporterMessenger;

    // Event emitted when a message is sent
    event MessageSent(
        bytes32 indexed messageID,
        bytes32 indexed destinationBlockchainID,
        address indexed destinationAddress,
        string message
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
     * @dev Send a message to another chain without a fee
     * @param destinationBlockchainID The blockchain ID of the destination chain
     * @param destinationAddress The address of the contract to receive the message on the destination chain
     * @param message The message to send
     * @return messageID The ID of the message sent
     */
    function sendMessage(
        bytes32 destinationBlockchainID,
        address destinationAddress,
        string calldata message
    ) external returns (bytes32) {
        return
            _sendMessage(
                destinationBlockchainID,
                destinationAddress,
                message,
                address(0),
                0
            );
    }

    /**
     * @dev Send a message to another chain with a fee
     * @param destinationBlockchainID The blockchain ID of the destination chain
     * @param destinationAddress The address of the contract to receive the message on the destination chain
     * @param message The message to send
     * @param feeTokenAddress The address of the token to use for the fee
     * @param feeAmount The amount of tokens to use for the fee
     * @return messageID The ID of the message sent
     */
    function sendMessageWithFee(
        bytes32 destinationBlockchainID,
        address destinationAddress,
        string calldata message,
        address feeTokenAddress,
        uint256 feeAmount
    ) external returns (bytes32) {
        // If a fee is specified, transfer the tokens from the sender to this contract
        if (feeAmount > 0 && feeTokenAddress != address(0)) {
            IERC20(feeTokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                feeAmount
            );

            // Approve the teleporter to spend the fee
            IERC20(feeTokenAddress).forceApprove(
                teleporterMessenger,
                feeAmount
            );
        }

        return
            _sendMessage(
                destinationBlockchainID,
                destinationAddress,
                message,
                feeTokenAddress,
                feeAmount
            );
    }

    /**
     * @dev Internal function to send a message
     */
    function _sendMessage(
        bytes32 destinationBlockchainID,
        address destinationAddress,
        string calldata message,
        address feeTokenAddress,
        uint256 feeAmount
    ) private returns (bytes32) {
        // Create the message input
        TeleporterMessageInput memory messageInput = TeleporterMessageInput({
            destinationBlockchainID: destinationBlockchainID,
            destinationAddress: destinationAddress,
            feeInfo: TeleporterFeeInfo({
                feeTokenAddress: feeTokenAddress,
                amount: feeAmount
            }),
            requiredGasLimit: 300000, // Default gas limit
            allowedRelayerAddresses: new address[](0), // Allow any relayer
            message: abi.encode(message) // Encode the message
        });

        // Send the message through teleporter
        bytes32 messageID = ITeleporterMessenger(teleporterMessenger)
            .sendCrossChainMessage(messageInput);

        // Emit event
        emit MessageSent(
            messageID,
            destinationBlockchainID,
            destinationAddress,
            message
        );

        return messageID;
    }
}
