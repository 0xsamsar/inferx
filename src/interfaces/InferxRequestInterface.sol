// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface InferxRequestInterface {
  function inferencerRequest(
    bytes32 modelId,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 nonce,
    bytes calldata data
  ) external;
}