// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Inferx.sol";
import "./interfaces/InferxRequestInterface.sol";
import "./interfaces/InferencerInterface.sol";


contract InferxClient {
  using Inferx for Inferx.Request;

  uint256 public result = 0;
  uint256 public requestCount = 1;
  mapping(bytes32 => address) private pendingRequests;

  InferencerInterface private inferencer;

  event InferxRequested(bytes32 indexed id);
  event InferxFulfilled(bytes32 indexed id);


  function buildInferxRequest(
    bytes32 modelId,
    address callbackAddr,
    bytes4 callbackFunctionSignature
  ) external pure returns (Inferx.Request memory) {
    Inferx.Request memory req;
    return req.initialize(modelId, callbackAddr, callbackFunctionSignature);
  }

  /**
   * @notice Creates an Inferx request to the specified node address
   * @dev Generates and stores a request ID
   * Emits InferxRequested event.
   * @param inferencerAddress The address of the inferencing node for the request
   * @param req The initialized Inferx Request
   * @return requestId The request ID
   */
  function sendInferxRequestTo(
    address inferencerAddress,
    Inferx.Request memory req
  ) external returns (bytes32 requestId) {
    uint256 nonce = requestCount;
    bytes memory encodedRequest = abi.encodeWithSelector(
      InferxRequestInterface.inferencerRequest.selector,
      req.modelId,
      req.callbackAddress,
      req.callbackFunctionId,
      nonce,
      req.data
    );
    return _rawRequest(inferencerAddress, nonce, encodedRequest);
  }

  /**
   * @notice Make a request to an inferencing node
   * @param inferencerAddress The address of the inferencing node for the request
   * @param nonce used to generate the request ID
   * @param encodedRequest data encoded for request type specific format
   * @return requestId The request ID
   */
  function _rawRequest(
    address inferencerAddress,
    uint256 nonce,
    bytes memory encodedRequest
  ) private returns (bytes32 requestId) {
    requestId = keccak256(abi.encodePacked(this, nonce));
    pendingRequests[requestId] = inferencerAddress;
    emit InferxRequested(requestId);
    (bool success, ) = inferencerAddress.call(encodedRequest);
    requestCount += 1;
    require(success, "unable to call inferencing node");
  }

  /**
   * @notice Sets the stored node address
   * @param inferencerAddress The address of the oracle contract
   */
  function setInferencer(address inferencerAddress) internal {
    inferencer = InferencerInterface(inferencerAddress);
  }

  /**
   * @notice Retrieves the stored address of the inferencer contract
   * @return The address of the node contract
   */
  function getInferencer() internal view returns (address) {
    return address(inferencer);
  }

  function fulfill(bytes32 requestId, bytes32 res)
    public
    recordInferxFulfillment(requestId)
    {
        result = uint256(res);
    }

  /**
   * @dev Reverts if the sender is not the node of the request.
   * Emits InferxFulfilled event.
   * @param requestId The request ID for fulfillment
   */
  modifier recordInferxFulfillment(bytes32 requestId) {
    require(msg.sender == pendingRequests[requestId], "Source must be the node of the request");
    delete pendingRequests[requestId];
    emit InferxFulfilled(requestId);
    _;
  }
}
