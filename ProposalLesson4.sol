// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProposalContract {
    // Besitzer des Contracts
    address public owner;
    
    // Zähler für die IDs der Vorschläge
    uint256 private proposalCounter;

    // Die Struktur für einen Vorschlag (inklusive deinem 'title'-Feld)
    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool active;
    }

    // Mapping von der Proposal-ID zum Vorschlag
    mapping(uint256 => Proposal) public proposals;
    
    // Mapping um zu prüfen, ob eine Adresse für einen bestimmten Vorschlag schon gestimmt hat
    // Proposal-ID => (Wähler-Adresse => hat_gestimmt)
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Events für das Frontend
    event ProposalCreated(uint256 indexed proposalId, string title);
    event Voted(uint256 indexed proposalId, address indexed voter, uint8 voteType);

    // Modifier: Nur der Besitzer darf die Funktion aufrufen
    modifier onlyOwner() {
        require(msg.sender == owner, "Nur der Besitzer kann diese Aktion durchfuehren");
        _;
    }

    // Modifier: Prüft, ob der Vorschlag noch aktiv ist
    modifier activeProposal(uint256 _proposalId) {
        require(proposals[_proposalId].active, "Dieser Vorschlag ist nicht mehr aktiv");
        _;
    }

    // Modifier: Prüft, ob die Adresse noch NICHT abgestimmt hat
    modifier hasNotVoted(uint256 _proposalId) {
        require(!hasVoted[_proposalId][msg.sender], "Du hast fuer diesen Vorschlag bereits abgestimmt");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Funktion zum Erstellen eines neuen Vorschlags
    function create(
        string memory _title,
        string memory _description,
        uint256 _total_vote_to_end
    ) external onlyOwner {
        proposalCounter++;
        
        proposals[proposalCounter] = Proposal({
            title: _title,
            description: _description,
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: _total_vote_to_end,
            active: true
        });

        emit ProposalCreated(proposalCounter, _title);
    }

    // Funktion zum Abstimmen
    // _voteType: 1 = Approve, 2 = Reject, 3 = Pass
    function vote(uint256 _proposalId, uint8 _voteType) 
        external 
        activeProposal(_proposalId) 
        hasNotVoted(_proposalId) 
    {
        Proposal storage p = proposals[_proposalId];
        
        if (_voteType == 1) {
            p.approve++;
        } else if (_voteType == 2) {
            p.reject++;
        } else if (_voteType == 3) {
            p.pass++;
        } else {
            revert("Ungueltiger Vote-Typ. Benutze 1 (Approve), 2 (Reject) oder 3 (Pass)");
        }

        hasVoted[_proposalId][msg.sender] = true;
        emit Voted(_proposalId, msg.sender, _voteType);

        // Wenn die maximale Stimmenanzahl erreicht ist, wird der Vorschlag beendet
        if ((p.approve + p.reject + p.pass) >= p.total_vote_to_end) {
            p.active = false;
        }
    }

    // HIER IST DEINE NEUE LOGIK: Einfache Mehrheit (Option A)
    // Gibt true zurück, wenn die Ja-Stimmen strikt größer als die Nein-Stimmen sind.
    // Enthaltungen (pass) werden komplett ignoriert.
    function calculateCurrentState(uint256 _proposalId) external view returns (bool) {
        Proposal memory p = proposals[_proposalId];
        return p.approve > p.reject;
    }
}
