// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { DssExec } from "dss-exec-lib/DssExec.sol";
import { DssAction } from "dss-exec-lib/DssAction.sol";
import { DSPauseProxy } from "ds-pause/pause.sol";

interface HatsLike {
    function mintTopHat(address _target, string memory _details, string memory _imageURI)
        external
        returns (uint256 topHatId);
}

contract DssSpellAction is DssAction {
    // https://etherscan.io/address/0xbe8e3e3618f7474f8cb1d074a26affef007e98fb
    // DSPauseProxy public constant pauseProxy = 0xBE8E3e3618f7474F8cB1d074A26afFef007E98FB;

    address public constant HATS = address(0); // TODO: fill with the hats contract instance;

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
        // https://vote.makerdao.com/polling/TODO#poll-detail TODO: UPDATE THIS ONCE THERE'S A POLL

        /* For security & separation of concerns reasons, we create a new proxy to wear 
         * the tophat. The new proxy is owned/controlled by the original pauseProxy.

         * Since minting a tophat can be done on behalf of another contract, the present 
         * spell is straightforward and can be executed within the context of the 
         * pauseProxy.
         * 
         * However, subsequent executive spells operating under this tophat will need to * executed from the context of the new proxy, which will require using something 
         * like the following pattern of spell actions:
         *
         *  1. Generate the abi-encoded bytes for a tx to be called against Hats.sol
         *  2. Call `pauseHatsProxy.exec(usr: Hats.sol, fax: the_bytes_from_1);`
         * 
         * This will execute the Hats tx from the execution context of the pauseHatsProxy.
         */

        // deploy a new DSPauseProxy that will be owned by the original pauseProxy
        DSPauseProxy pauseHatsProxy = new DSPauseProxy(); // owner == msg.sender == pauseProxy

        // mint a tophat to the hatsPauseProxy
        uint256 topHatId = HatsLike(HATS).mintTopHat(
            address(hatsPauseProxy),
            // the tophat's details and imageURI can both be updated later
            "", // TODO MakerDAO to decide which details to use initially
            "" // TODO MakerDAO to decide which image to use initially
        );
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) { }
}
