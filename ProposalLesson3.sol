// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    uint256 private counter;

    struct Proposal {
        string title;               // Neues Feld aus deiner Challenge
        string description;         // Beschreibung des Vorschlags
        uint256 approve;            // Anzahl der Ja-Stimmen
        uint256 reject;             // Anzahl der Nein-Stimmen
        uint256 pass;               // Anzahl der Enthaltungen
        uint256 total_vote_to_end;  // Limit, bei dem die Abstimmung endet
        bool current_state;         // Zeigt an, ob der Vorschlag angenommen wurde
        bool is_active;             // Zeigt an, ob noch abgestimmt werden kann
    }

    mapping(uint256 => Proposal) proposal_history;

    // Aktualisierte Funktion mit dem _title Parameter
    function create(
        string calldata _title, 
        string calldata _description, 
        uint256 _total_vote_to_end
    ) external {
        counter += 1;
        
        // Das neue Struct wird inklusive Titel in das Mapping geschrieben
        proposal_history[counter] = Proposal(
            _title, 
            _description, 
            0, 
            0, 
            0, 
            _total_vote_to_end, 
            false, 
            true
        );
    }
}
