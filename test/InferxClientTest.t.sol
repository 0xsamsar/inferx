// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Inferx.sol";
import "../src/InferxClient.sol";
import "./mocks/MockInferencer.sol";

contract InferxClientTest is Test {
    using Inferx for Inferx.Request;

    event InferencerRequested(
        bytes32 indexed modelId,
        bytes32 requestId,
        address callbackAddr,
        bytes4 callbackFunctionId,
        uint256 nonce,
        bytes data
    );

    MockInferencer public mockInferencer;
    InferxClient public inferxClient;

    bytes32 modelId;
    address callbackAddr;
    bytes4 callbackFunctionSignature;

    uint256 constant RESPONSE = 112358;
    bytes constant query = "DEADBEEF";

    function setUp() public {
        mockInferencer = new MockInferencer();
        inferxClient = new InferxClient();

        modelId = "0xDEAD";
        callbackAddr = address(inferxClient);
        callbackFunctionSignature = inferxClient.fulfill.selector;
    }

    function testCanCreateRequest() public {
        bytes32 mockRequestId = keccak256(abi.encodePacked(callbackAddr, inferxClient.requestCount()));
        Inferx.Request memory req = inferxClient.buildInferxRequest(modelId, callbackAddr, callbackFunctionSignature, query);
        bytes32 requestId = inferxClient.sendInferxRequestTo(address(mockInferencer), req);
        assertTrue(mockRequestId == requestId);
    }

    function testCanFulfillRequest() public {
        Inferx.Request memory req = inferxClient.buildInferxRequest(modelId, callbackAddr, callbackFunctionSignature, query);
        bytes32 requestId = inferxClient.sendInferxRequestTo(address(mockInferencer), req);
        mockInferencer.fulfillInferencerRequest(requestId, bytes32(RESPONSE));
        assertTrue(inferxClient.result() == RESPONSE);
    }

    function testExpectEmitInferencerRequested() public {
        bytes32 mockRequestId = keccak256(abi.encodePacked(callbackAddr, inferxClient.requestCount()));
        Inferx.Request memory req = inferxClient.buildInferxRequest(modelId, callbackAddr, callbackFunctionSignature, query);
        vm.expectEmit(true, false, false, true);
        emit InferencerRequested(modelId, mockRequestId, callbackAddr, callbackFunctionSignature, inferxClient.requestCount(), query);
        inferxClient.sendInferxRequestTo(address(mockInferencer), req);
        }
}