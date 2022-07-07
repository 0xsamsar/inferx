// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./InferxRequestInterface.sol";

interface InferencerInterface {
  function fulfillInferencerRequest(
    bytes32 requestId,
    bytes32 data
  ) external returns (bool);
}