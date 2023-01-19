// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "hats-protocol/Interfaces/IHats.sol";
import { DSPauseProxy, DSPause } from "ds-pause/pause.sol";

contract DssSpellAction is DssAction {
    DSPauseProxy public pauseHatsProxy;
    IHats public hats;

    constructor(IHats _hats) {
        hats = _hats;
    }

    // QUESTION: Should office hours be on?
    function officeHours() public override returns (bool) {
        return false;
    }

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://<executive-vote-canonical-post> -q -O - 2>/dev/null)"
    function description() external view override returns (string memory) {
        // TODO
    }

    // DssAction developer must override `actions()` and place all actions to be called inside.
    //   The DssExec function will call this subject to the officeHours limiter
    //   By keeping this function public we allow simulations of `execute()` on the actions outside of the cast time.
    function actions() public override {
        // 1. deploy a new DSPauseProxy
        pauseHatsProxy = new DSPauseProxy();

        // 2. mint a tophat to DSPauseHatsProxy
        hats.mintTopHat(
            pauseHatsProxy, // will wear the tophat
            _details, // QUESTION what details should we enter?
            _imageURI // QUESTION what image, if any, should be used for MakerDAO hats?
        );
    }
}

contract DssSpell is DssExec {
    constructor(IHats _hats) DssExec(block.timestamp + 30 days, address(new DssSpellAction(_hats))) { }
}
