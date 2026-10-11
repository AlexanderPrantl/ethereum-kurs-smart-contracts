// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {

    struct Proposal {
        string title; // HIER hinzugefügt: Titel des Vorschlags
        string description; // Beschreibung des Vorschlags
        uint256 approve; // Anzahl der Ja-Stimmen
        uint256 reject; // Anzahl der Nein-Stimmen
        uint256 pass; // Anzahl der Enthaltungen
        uint256 total_vote_to_end; // Limit, bei dem die Abstimmung endet
        bool current_state; // Zeigt an, ob der Vorschlag angenommen oder abgelehnt wurde
        bool is_active; // Zeigt an, ob die Abstimmung noch läuft
    }

    mapping(uint256 => Proposal) proposal_history; // Das Archiv für die Vorschläge
}
