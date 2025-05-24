// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.18;

import "@teleporter/ITeleporterMessenger.sol";
import "@teleporter/ITeleporterReceiver.sol";

contract MessageReceiver is ITeleporterReceiver {
    ITeleporterMessenger public immutable messenger =
        ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    string public lastMessage;

    function receiveTeleporterMessage(
        bytes32,
        address,
        bytes calldata message
    ) external {
        // Only the Interchain Messaging receiver can deliver a message.
        require(
            msg.sender == address(messenger),
            "ReceiverOnDispatch: unauthorized TeleporterMessenger"
        );

        // Store the message.
        lastMessage = abi.decode(message, (string));
    }
}
