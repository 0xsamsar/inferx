// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/Inferx.sol";
import "../../src/interfaces/InferencerInterface.sol";
import "../../src/interfaces/InferxRequestInterface.sol";

contract MockInferencer is InferxRequestInterface {
    using Inferx for Inferx.Request;
    uint256 private constant MINIMUM_CONSUMER_GAS_LIMIT = 400000;

    mapping(bytes32 => Inferx.Request) private commitments;

    event InferencerRequested(
        bytes32 indexed modelId,
        bytes32 requestId,
        address callbackAddr,
        bytes4 callbackFunctionId,
        uint256 nonce,
        bytes data
    );

    function inferencerRequest(
        bytes32 modelId,
        address callbackAddress,
        bytes4 callbackFunctionId,
        uint256 nonce,
        bytes calldata data
    ) external {
        bytes32 requestId = keccak256(abi.encodePacked(callbackAddress, nonce));
        require(
            commitments[requestId].callbackAddress == address(0),
            "Must use a unique ID"
        );

        commitments[requestId] = Inferx.Request(modelId, callbackAddress, callbackFunctionId, nonce, data);

        emit InferencerRequested(
            modelId,
            requestId,
            callbackAddress,
            callbackFunctionId,
            nonce,
            data
        );
    }

    function fulfillInferencerRequest(
        bytes32 _requestId, 
        bytes32 _data
    ) external
        isValidRequest(_requestId)
        returns (bool)
    {
        Inferx.Request memory req = commitments[_requestId];
        delete commitments[_requestId];
        require(
            gasleft() >= MINIMUM_CONSUMER_GAS_LIMIT,
            "Must provide consumer enough gas"
        );
        (bool success, ) = req.callbackAddress.call(
            abi.encodeWithSelector(req.callbackFunctionId, _requestId, _data)
        ); // solhint-disable-line avoid-low-level-calls
        return success;
    }

    /**
     * @dev Reverts if request ID does not exist
     * @param _requestId The given request ID to check in stored `commitments`
     */
    modifier isValidRequest(bytes32 _requestId) {
        require(
            commitments[_requestId].callbackAddress != address(0),
            "Must have a valid requestId"
        );
        _;
    }

}
