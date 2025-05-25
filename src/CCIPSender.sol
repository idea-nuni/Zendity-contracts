// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";
// import {IRouterClient} from "@chainlink/contracts-ccip/contracts/interfaces/IRouterClient.sol";
import {IERC20} from "@chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";

contract CCIPSender {
    IRouterClient public ccipRouter;
    IERC20 private s_linkToken;

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        string text, // The text being sent.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );

    constructor(address routerAddress, address _link) {
        ccipRouter = IRouterClient(routerAddress);
        s_linkToken = IERC20(_link);
    }

    /// @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token.
    /// @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    /// @param _beneficiary The address to which the tokens will be sent.
    /// @param _token The contract address of the ERC20 token to be withdrawn.
    function withdrawToken(address _beneficiary, address _token) public {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        require(amount > 0, "Nothing to withdraw");

        IERC20(_token).transfer(_beneficiary, amount);
    }

    function sendSignature(
        address _receiver,
        string calldata _text,
        uint64 _destinationChainSelector
    ) external returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory message = _buildCCIPMessage(
            _receiver,
            _text,
            address(s_linkToken)
        );

        uint256 fees = ccipRouter.getFee(_destinationChainSelector, message);
        s_linkToken.approve(address(ccipRouter), fees);
        messageId = ccipRouter.ccipSend{value: fees}(
            _destinationChainSelector,
            message
        );

        // Emit an event with message details
        emit MessageSent(
            messageId,
            _destinationChainSelector,
            _receiver,
            _text,
            address(s_linkToken),
            fees
        );

        return messageId;
    }

    function _buildCCIPMessage(
        address _receiver,
        string calldata _text,
        address _feeTokenAddress
    ) private pure returns (Client.EVM2AnyMessage memory) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(_receiver), // ABI-encoded receiver address
                data: abi.encode(_text), // ABI-encoded string
                tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array as no tokens are transferred
                extraArgs: "",
                feeToken: _feeTokenAddress
            });
    }
}
