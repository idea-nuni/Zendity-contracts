// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.25;

import "@teleporter/ITeleporterMessenger.sol";

contract UserProofHub {
    ITeleporterMessenger public immutable messenger =
        ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    // Mapping to store user address proof hashes
    mapping(address => bytes32) public userProofHashes;

    // Event emitted when a user proof is verified and stored
    event ProofVerified(address indexed user, bytes32 proofHash);

    // Event emitted when a message is sent
    event MessageSent(
        bytes32 indexed messageID,
        address indexed destinationAddress,
        bytes32 indexed destinationBlockchainID,
        string message
    );

    /**
     * @dev Verifies and stores a proof hash for a user address
     * @param user The user address to associate with the proof
     * @param proofHash The hash representing the user's proof
     */
    function verify(address user, bytes32 proofHash) external {
        require(user != address(0), "Invalid user address");
        require(proofHash != bytes32(0), "Invalid proof hash");

        // Store the proof hash for the user
        userProofHashes[user] = proofHash;

        emit ProofVerified(user, proofHash);
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

    /**
     * @dev Sends a message to another chain.
     */
    function transportProof(
        address destinationAddress,
        bytes32 destinationBlockchainID,
        string calldata message
    ) external returns (bytes32) {
        bytes32 messageID = messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                // BlockchainID of Dispatch L1
                destinationBlockchainID: destinationBlockchainID,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({
                    feeTokenAddress: address(0),
                    amount: 0
                }),
                requiredGasLimit: 100000,
                allowedRelayerAddresses: new address[](0),
                message: abi.encode(message)
            })
        );

        emit MessageSent(
            messageID,
            destinationAddress,
            destinationBlockchainID,
            message
        );
        return messageID;
    }
}
