// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "hats-protocol/Interfaces/IHats.sol";
import { DSPauseProxy } from "ds-pause/pause.sol";

contract DssSpellAction is DssAction {
    DSPauseProxy public pauseHatsProxy;

    // https://etherscan.io/address/0xbe8e3e3618f7474f8cb1d074a26affef007e98fb
    // DSPauseProxy public constant pauseProxy = 0xBE8E3e3618f7474F8cB1d074A26afFef007E98FB;

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
        // 1. deploy a new DSPauseProxy that will be owned by the original pauseProxy
        pauseHatsProxy = new DSPauseProxy(); // owner == msg.sender == pauseProxy

        // 2. mint a tophat to the pause proxy, which is the msg.sender
        hats.mintTopHat(
            pauseHatsProxy,
            _details, // QUESTION what details should we enter?
            _imageURI // QUESTION what image, if any, should be used for MakerDAO hats?
        );

        /* Subsequent executive spells operating under this tophat will need to use the 
         * following pattern:
         *
         *  1. Craft an abi-encoded tx to be called against Hats.sol
         *  2. Call pauseHatsProxy.exec(usr: Hats.sol, fax: the_bytes_from_1);
         * 
         * This will execute the Hats tx from the execution context of the pauseHatsProxy.
         */
    }
}

contract DssSpell is DssExec {
    constructor(IHats _hats) DssExec(block.timestamp + 30 days, address(new DssSpellAction(_hats))) { }
}
