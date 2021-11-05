// version non finalisée - reste quelques optimisations, améliorations, et tests  - je continue dessus + tard. 


// SPDX-License-Identifier: GPL-3.0

//pragma solidity >=0.7.0 <0.9.0;

//pragma solidity 0.8.9; // last version : 03/11/2021  !!! différent dans remix ! 0.8.7+commit.e28d00a7 

//pragma solidity 0.8.7+commit.e28d00a7 ;
pragma solidity 0.8.7 ;  // last version : 03/11/2021  !!! différent dans remix ! 0.8.7+commit.e28d00a7 

// import openzeppling : 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

/** 
 * @title Voting
 * @dev Implements a voting process 
 */
contract Voting {
    
    // TODO 01 
    // set admin :  msg.sender par défaut 
    // faire une fct setAdmin pour changer admin si nécessaire ... 
    address public voteAdmin = msg.sender; 
    
    // les ints ici : 
    uint public winningProposalId; // voir si on garde (fct getWinner) :
    
    // Structs : 
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
        //uint votedProposalId;
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        uint proposalId; 
        string prop; 
        // moins coûteux que string - comparaison des chaines plus rapide 
        
        // string description;
        uint voteCount; // number of accumulated votes
        
        
    }
    
    mapping(address => Voter) public voters;
    
    // vote status : 
    enum WorkflowStatus {
        
        RegisteringVoters,              // State 01 : Registering Voters 
        ProposalsRegistrationStarted,   // State 02 : Proposals - Started registration
        ProposalsRegistrationEnded,     // State 03 : Proposals - Ended registration
        VotingSessionStarted,           // State 04 : Votes - Started Voting 
        VotingSessionEnded,             // State 05 : Votes - Ended Voting
        VotesTallied                    // State 06 : VotesTallied
    }
    
    // Events : 4 events to watch ... 
    event VoterRegistered(address voterAddress);                                            // E01 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);    // E02
    // event ProposalRegistered(uint proposalId);                                              // E03
    event ProposalRegistered(string proposalId);                                              // E03
    event Voted (address voter, uint proposalId);                                           // E04 

    Proposal[] public proposals;
    
    
    
    // vote status :
    WorkflowStatus public voteStatus  = WorkflowStatus.RegisteringVoters;
    
    // Process :
    // Task 01 - liste de voters whitelist : 
    
    // Task 02 - start recording proposals : 
    // Solution 1 - admin enregistre 
    // construite le tableau des proposals  : 
    // constructor(string[] memory _listProposals) {
    
    
    // pas utilisé pour cet exemple : 
    /**
    constructor(string[] memory _listProposals) {
        
        //Voter memory _newVoter ;
        
        for (uint i = 0; i < _listProposals.length; i++) {
            
            proposals.push(Proposal({
                proposalId: i, 
                prop: _listProposals[i],
                voteCount: 0
            }));
        }
    } 
    */
    
    // Solution 2 - chaque voter peut enregistrer ses propositions: - demandé dans l'énoncé : 
    
    function propose(uint _id , string memory _prop) public {
            
            // check vote status : 
            require(voteStatus == WorkflowStatus.ProposalsRegistrationStarted , "Registration not stated");
            proposals.push(Proposal( {
                // modifier : 
                // description: _prep,
                proposalId: _id,
                prop: _prop,
                voteCount: 0
            } 
            )
            );
            // event : 
            emit ProposalRegistered(_prop);
    }
        
    function registerVoter(address _voter) public {
        
        // pré-requis : 
        // 1 - admin enregistre le voter 
        require( msg.sender == voteAdmin, "Only Admin can give right to vote.");
        // 2 - s'il n'a pas voté 
        require( !voters[_voter].hasVoted, "Voted !");  
        // 3 - si voter n'est pas enregistré 
        require (!voters[_voter].isRegistered, "already Registred");
        
        voters[_voter].votedProposalId = 0;
        
        emit VoterRegistered(_voter); 
    }
    
        // Voters :
        // Task 02 - whitelist  : 
        // construite la liste de voters   :  liste address : 
        
    function makeListVoters ( address[] memory _voters ) public {
            
            for (uint i = 0; i < _voters.length; i++) {
            
                registerVoter(_voters[i]);
            
            }
            
            // new status : 
            
            //emit event WorkflowStatusChange( previousStatus,  newStatus);
            emit WorkflowStatusChange(voteStatus, WorkflowStatus.ProposalsRegistrationStarted); 
            
            voteStatus = WorkflowStatus.ProposalsRegistrationStarted;
        
    }
    
    // events :
    
    // Session 2 - Vote :
    
    function voter( Voter memory _curVoter, uint _proposal) public {
        
        // prérequis du vote : 
        // 1 - require sur état du vote : lancé - ajouter : 
        
        // 2 - voter enregistré et n'a pas encore voté 
        // map
        // current voter : 
        //voter curVoter    = voters[msg.sender];
        
        // fait après les requires :
        //_curVoter.hasVoted = true;
        //_curVoter.votedProposalId = _proposal;
        //voters[msg.sender] = _curVoter; fait après les requires :
        
        require(voteStatus == WorkflowStatus.VotingSessionStarted , "Vote not stated");
        require(_curVoter.isRegistered , "Voter not registered - please try later");
        require(!_curVoter.hasVoted, "Voter has already voted - No Chance to cheat!");
        
        // comptabiliser le vote : 
        proposals[_proposal].voteCount += 1;
        _curVoter.hasVoted = true;
        _curVoter.votedProposalId = _proposal;
        voters[msg.sender] = _curVoter;
        // event voted  : 
        emit Voted(msg.sender, _proposal);
    
    }
    
    // get the winner : 
    // 2 solutions différentes pour getWinner 
    // error identifier ! why ? 
    // commented pour éliminer les err de compil - et chercher la cause :
    // remplacée par getWinnerVote
    /****
    function winner() public returns(unint) {
        // show the Winner : 
        // trouver le winner avec max votes - boucle sur proposals et get max nb votes 
        
        uint  winnerIndex;
        for (uint i = 1; i < proposals.length; i++) {
            
            if (proposals[winnerIndex].voteCount < proposals[i].voteCount) {
                winnerIndex = i;
               
            }
        }
        // winningProposalId = winnerIndex;
        return winnerIndex;
        
    }
    */
    
    function getWinnerVote() public returns(uint, uint){
        // show the Winner - return index and nb votes for the winner - 
        // trouver le winner avec max votes - boucle sur proposals et get max nb votes 
    uint maxVote;
    uint maxIndex;

    for (uint i = 0; i < proposals.length; i++) {
        if (proposals[i].voteCount > maxVote) {
            maxVote = proposals[i].voteCount;
            maxIndex = i; 
        }
    }
    winningProposalId = maxIndex;
    return (winningProposalId, maxVote);
    }
    
    // show winner : 
    function showWinnerProp() public view returns (string memory, uint) {
        // show the Winner : 
            
        return (proposals[winningProposalId].prop , proposals[winningProposalId].voteCount);
        
    }
    
    
   
}
