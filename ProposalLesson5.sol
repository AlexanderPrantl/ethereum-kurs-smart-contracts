// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    // ****************** Data ***********************

    // Besitzer des Contracts
    address public owner;

    // Zähler für die IDs der Vorschläge
    uint256 private counter;

    // Die Struktur für einen Vorschlag (inklusive deinem 'title'-Feld)
    struct Proposal {
        string title; // Dein eigenes Titel-Feld
        string description; // Beschreibung des Vorschlags
        uint256 approve; // Anzahl der Ja-Stimmen
        uint256 reject; // Anzahl der Nein-Stimmen
        uint256 pass; // Anzahl der Enthaltungen
        uint256 total_vote_to_end; // Stimmlimit, bei dem der Vorschlag endet
        bool current_state; // Gibt an, ob der Vorschlag angenommen wurde
        bool is_active; // Gibt an, ob noch abgestimmt werden kann
    }

    // Archiv für alle Vorschläge
    mapping(uint256 => Proposal) proposal_history;

    // Liste aller Adressen, die beim aktuellen Vorschlag abgestimmt haben
    address[] private voted_addresses; 

    // Events für das Frontend / Remix
    event ProposalCreated(uint256 indexed proposalId, string title);
    event Voted(uint256 indexed proposalId, address indexed voter, uint8 choice);

    // ****************** Modifier ***********************

    modifier onlyOwner() {
        require(msg.sender == owner, "Nur der Besitzer kann diese Aktion durchfuehren");
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true, "Dieser Vorschlag ist nicht mehr aktiv");
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Du hast fuer diesen Vorschlag bereits abgestimmt");
        _;
    }

    // Constructor setzt den Ersteller als Besitzer fest
    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    // ****************** Execute Functions ***********************

    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    // Erstellen eines neuen Vorschlags (Inklusive _title)
    function create(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_title, _description, 0, 0, 0, _total_vote_to_end, false, true);
        emit ProposalCreated(counter, _title);
    }
    
    // Funktion zum Abstimmen (1 = Approve, 2 = Reject, 0 = Pass)
    function vote(uint8 choice) external active newVoter(msg.sender) {
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        } else {
            revert("Ungueltiger Vote-Typ. Benutze 1 (Approve), 2 (Reject) oder 0 (Pass)");
        }

        emit Voted(counter, msg.sender, choice);

        // Wenn das Limit erreicht ist, wird der Vorschlag geschlossen
        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner]; // Setzt die Wählerliste für den nächsten Vorschlag zurück
        }
    }

    // Vorzeitiges Beenden durch den Admin
    function terminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
    }

    // DEINE EIGENE LOGIK: Einfache Mehrheit
    // Gibt true zurück, wenn approve strikt größer als reject ist. Pass (Enthaltungen) wird ignoriert.
    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];
        return proposal.approve > proposal.reject;
    }

    // ****************** Query Functions ***********************

    // Prüft, ob eine Adresse bereits für den aktuellen Vorschlag gestimmt hat
    function isVoted(address _address) public view returns (bool) {
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }

    // Gibt den aktuellen Live-Vorschlag zurück
    function getCurrentProposal() external view returns(Proposal memory) {
        return proposal_history[counter];
    }

    // Gibt einen spezifischen Vorschlag anhand der ID zurück
    function getProposal(uint256 number) external view returns(Proposal memory) {
        return proposal_history[number];
    }
}
