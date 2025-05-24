// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.25;

import "@teleporter/ITeleporterMessenger.sol";
import "@teleporter/ITeleporterReceiver.sol";

contract UserProofReceiver is ITeleporterReceiver {
    ITeleporterMessenger public immutable messenger =
        ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    // Mapping to store received user proof hashes
    mapping(address => bytes32) public userProofHashes;

    // Event emitted when a proof is received and stored
    event ProofReceived(
        bytes32 indexed sourceBlockchainID,
        address indexed originSender,
        address indexed account,
        bytes32 proofHash
    );

    /**
     * @dev Implements ITeleporterReceiver interface
     * Receives and stores user account and proof hash from another chain
     */
    function receiveTeleporterMessage(
        bytes32 sourceBlockchainID,
        address originSenderAddress,
        bytes calldata message
    ) external override {
        // Only the Interchain Messaging receiver can deliver a message.
        require(
            msg.sender == address(messenger),
            "UserProofReceiver: unauthorized TeleporterMessenger"
        );

        // Decode the message to get account and proof hash
        (address account, bytes32 proofHash) = abi.decode(
            message,
            (address, bytes32)
        );

        // Validate the decoded data
        require(account != address(0), "Invalid account address");
        require(proofHash != bytes32(0), "Invalid proof hash");

        // Store the proof hash for the account
        userProofHashes[account] = proofHash;

        // Emit event for tracking
        emit ProofReceived(
            sourceBlockchainID,
            originSenderAddress,
            account,
            proofHash
        );
    }

    /**
     * @dev Gets the stored proof hash for a user
     * @param user The user address to query
     * @return The proof hash associated with the user
     */
    function getUserProofHash(address user) external view returns (bytes32) {
        return userProofHashes[user];
    }

    /**
     * @dev Checks if a user has a verified proof
     * @param user The user address to check
     * @return True if the user has a proof hash stored
     */
    function isUserVerified(address user) external view returns (bool) {
        return userProofHashes[user] != bytes32(0);
    }
}
