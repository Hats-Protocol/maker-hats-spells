// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { DssExec } from "dss-exec-lib/DssExec.sol";
import { DssAction } from "dss-exec-lib/DssAction.sol";
import { IHats } from "hats-protocol/Interfaces/IHats.sol";
import { DSPauseProxy } from "ds-pause/pause.sol";

contract CreateHatAction is DssAction {
    DSPauseProxy public immutable pauseHatsProxy;

    IHats public immutable hats;
    uint256 public immutable tophat;

    constructor(IHats _hats, DSPauseProxy _pauseHatsProxy, uint256 _tophat) {
        hats = _hats;
        pauseHatsProxy = _pauseHatsProxy;
        tophat = _tophat;
    }

    function officeHours() public override returns (bool) {
        // TODO: Decide whether office hours should be on
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
        /* For security & separation of concerns reasons, MakerDAO's tophat is owned and 
         * controlled by a separate proxy called pauseHatsProxy.
         * 
         * Spells taking actions from or underneath the tophat must be executed from the 
         * context of the pauseHatsProxy, which will require using something like the 
         * following pattern:
         *
         *  1. Generate the abi-encoded bytes for a tx to be called against Hats.sol
         *  2. Call `pauseHatsProxy.exec(usr: Hats.sol, fax: the_bytes_from_1);`
         * 
         * This will execute the Hats tx from the execution context of the pauseHatsProxy.
         */
        // 0. define new hat parameters
        string memory details;
        uint32 maxSupply;
        address eligibility;
        address toggle;
        bool mutable_;
        string memory imageURI;

        // 1. generate the abi-encoded bytes for the createHat transaction to be called against Hats.sol
        bytes memory fax = abi.encodeWithSelector(
            IHats.CreateHat.selector,
            tophat, // admin
            details,
            maxSupply,
            eligibility,
            toggle,
            mutable_,
            imageURI
        );

        // 2. pass the fax as a payload to pauseHatsProxy
        pauseHatsProxy.exec(hats, fax);
    }
}

contract CreateHatSpell is DssExec {
    constructor(IHats _hats, DSPauseProxy _pauseHatsProxy, uint256 _tophat)
        DssExec(block.timestamp + 30 days, address(new DssSpellAction(_hats, _pauseHatsProxy, _tophat)))
    { }
}
