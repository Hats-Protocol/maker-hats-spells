// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { DssExec } from "dss-exec-lib/DssExec.sol";
import { DssAction } from "dss-exec-lib/DssAction.sol";

interface DSPauseProxyLike {
    function exec(address usr, bytes memory fax) external returns (bytes memory out);
}

interface HatsLike {
    function createHat(
        uint256 _admin,
        string memory _details,
        uint32 _maxSupply,
        address _eligibility,
        address _toggle,
        bool _mutable,
        string memory _imageURI
    ) external returns (uint256 newHatId);
}

contract DssSpellAction is DssAction {
    address public constant HATS = address(0); // TODO: fill with the hats contract instance
    address public constant HATS_PAUSE_PROXY = address(0); // TODO: fill with the hats pause proxy instance
    uint256 public constant TOP_HAT_ID = 0; // TODO: fill with the top hat ID created before

    string public HAT_DETAILS = ""; // TODO: fill with the details of the new hat
    uint32 public constant HAT_MAX_SUPPLY = 0; // TODO: fill with the max supply of the new hat
    address public constant HAT_ELIGIBILITY = address(0); // TODO: fill with the eligibility module address of the new hat
    address public constant HAT_TOGGLE = address(0); // TODO: fill with the toggle module address of the new hat
    bool public constant HAT_MUTABLE = false; // TODO: fill with the mutability of the new hat
    string public HAT_IMAGE_URI = ""; // TODO: fill with the imageURI of the new hat

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

        // 1. generate the abi-encoded bytes for the createHat transaction to be called against Hats.sol
        bytes memory fax = abi.encodeWithSelector(
            HatsLike(0).createHat.selector,
            TOP_HAT_ID, // admin
            HAT_DETAILS,
            HAT_MAX_SUPPLY,
            HAT_ELIGIBILITY,
            HAT_ELIGIBILITY,
            HAT_MUTABLE,
            HAT_IMAGE_URI
        );

        // 2. pass the fax as a payload to pauseHatsProxy to execute against Hats.sol
        DSPauseProxyLike(HATS_PAUSE_PROXY).exec(hats, fax);
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) { }
}
