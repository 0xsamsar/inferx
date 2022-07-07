// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library Inferx {

  struct Request {
    bytes32 modelId;
    address callbackAddress;
    bytes4 callbackFunctionId;
    uint256 nonce;
    bytes data;
  }

  /**
   * @notice Initializes an Inference request
   * @dev Sets the model ID, callback address, and callback function signature on the request
   * @param self The uninitialized request
   * @param modelId The Model Specification ID
   * @param callbackAddr The callback address
   * @param callbackFunc The callback function signature
   * @return The initialized request
   */
  function initialize(
    Request memory self,
    bytes32 modelId,
    address callbackAddr,
    bytes4 callbackFunc
  ) internal pure returns (Request memory) {
    self.modelId = modelId;
    self.callbackAddress = callbackAddr;
    self.callbackFunctionId = callbackFunc;
    return self;
  }
}