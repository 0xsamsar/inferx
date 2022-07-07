// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Inferx.sol";
import "../src/InferxClient.sol";
import "./mocks/MockInferencer.sol";

contract InferxClientTest is Test {
    using Inferx for Inferx.Request;

    MockInferencer public mockInferencer;
    InferxClient public inferxClient;

    bytes32 modelId;
    bytes32 blank_bytes32;
    address callbackAddr;
    bytes4 callbackFunctionSignature;

    uint256 constant RESPONSE = 112358;

    function setUp() public {
        mockInferencer = new MockInferencer();
        inferxClient = new InferxClient();

        modelId = "1";
        callbackAddr = address(inferxClient);
        callbackFunctionSignature = inferxClient.fulfill.selector;
        
    }

    function testCanCreateRequest() public {
        Inferx.Request memory req = inferxClient.buildInferxRequest(modelId, callbackAddr, callbackFunctionSignature);
        bytes32 requestId = inferxClient.sendInferxRequestTo(address(mockInferencer), req);
        mockInferencer.inferencerRequest(req.modelId, req.callbackAddress, req.callbackFunctionId, inferxClient.requestCount(), req.data);
        assertTrue(requestId != blank_bytes32);
    }

    function testCanFulfillRequest() public {
        Inferx.Request memory req = inferxClient.buildInferxRequest(modelId, callbackAddr, callbackFunctionSignature);
        bytes32 requestId = inferxClient.sendInferxRequestTo(address(mockInferencer), req);
        mockInferencer.inferencerRequest(req.modelId, req.callbackAddress, req.callbackFunctionId, inferxClient.requestCount(), req.data);
        mockInferencer.fulfillInferencerRequest(requestId, bytes32(RESPONSE));
        assertTrue(inferxClient.result() == RESPONSE);

    }
}