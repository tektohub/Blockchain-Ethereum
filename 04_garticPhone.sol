// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title garticPhone
 * @dev game garticPhone - guess the first Word !
 */

// Imports : 
// non utilisés ici - 

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol"; 

// url  : faire un clone ... 
// import "./node_modules/@openzeppelin/contracts/access/Ownable.sol"; 


// RAF :
// 1 - compare 2 strings : avec hash  - DONE 
// 2 - gérer mapping gamers : DONE 
// 3 - current word != lastWord ... dans addWord : DONE
// 4 - intégrer checkWord dans addWord - check winner en même temps + event end game .... ===>> DONE 
// 5 - gérer enum State game : Started Ongoing Ended Blocked  :  DONE 


contract garticPhoneGame {
    
    // Library : à faire ... 
    
    address public gameAdmin = msg.sender; // default 
    address public theWinner; 
    
    // counters - index:
    uint public nbWords = 20; 
    uint public curIndex; // peut être supprimé ... 
    
    // array of words 
    string[] public wordTab; 
    //string public firstWord; // change to private :
    string public firstWord  = "Hello";
    string public output = "Goodbye!";  // quand on a joué et perdu 
    
    
    // mapping ! 
    // option 2 : nbWords au lieu de bool - plus général - permet d'autres options du jeu: ex: jouer +ieurs fois:
    mapping(address=> uint) public gamers;
    
    // Events : 
    event goGame(bool);
    event ended(bool);
    event ongoing(bool); 
    
    // hashage 
    // keccak256(abi.encodePacked(_word)) // hash pour comparer 2 strings 
    bytes32 public hash1 = keccak256(abi.encodePacked(firstWord)); // "Hello" 
    // bytes32 public hash1 = keccak256(firstWord); // ne marche pas !
    
    // Enum 
    enum State { Started, Ended, Ongoing, Blocked }
    State public state = State.Blocked;
    
    
    // init des vars :  fait plus haut à la déclaration 
    
    // curIndex = wordTab.length; erreur ?!!
    // gameAdmin = msg.sender;  // par défaut 
    
    /**
    constructor(){
        gameAdmin=msg.sender;
    }
    
    */ 
    
    /**
    modifier onlyAdmin() { // Modifier
       require(
           msg.sender == gameAdmin, "Only Admin can call this.");
       
       _;
    }
    */ 

    
    function addFirstWord(string memory _first) public {
        
        // if _index = 0 onlyOwner;  pas nécessaire ici 
        // require 1er mot - only admin :  
        require(msg.sender == gameAdmin, "Seul l'admin peut lancer ce jeu !");
        
        // check : first word : 
        //require(curIndex == 0);
        // OR : une des 2 options suffit : 
        require(wordTab.length == 0);
        
        // msg.value ?
        
        
        wordTab.push(_first);
        // wordTab.push("Hello World");
        //wordTab.push(msg.value);
        //curIndex+=1 ; // garder curIndex ? ... à voir ... 
        emit goGame(true);
        firstWord = _first;
        gamers[msg.sender] = 1; // mapping 
        // game started !
        state = State.Started;
        
    }
    
    
    function addWord(string memory _word) public returns (string memory) {
        
         
        // require 1er mot - only sender - onlyowner - 
        // comment vérifier les valeurs d'un event - 
        // require(event ended(false));
        
        // test si joueur a déjà joué : use mapping gamers :
        // check mapping : gamer played ! 
        // check nexiste pas mapping 
        //require(gamers[msg.sender] == 0 );  // le joueut n'a pas encore joué - 1er jeu : 
        //require(gamers[msg.sender] < 1 );  // le joueut n'a pas encore joué - 1er jeu :
        // OR undefined 
        
        // check if game ended : event ... vérifier si un event a été émis : 
        
        require(state == State.Started, "Game not started. Please try later");
        
        require(gamers[msg.sender] < 20 );  // test pour 1 joueur - droit de jouer 
        
        // le tableau n'est pas plein : moins de nbwords : 20 mots dans notre exemple 
        // require(curIndex < 20 ); // use length de wordTab -  nbWords
        require(curIndex < nbWords ); // use length de wordTab -  nbWords
        
        // getLastWord() != _word 
        
        //success = compare2Strings (first, _word );
        require ( !compare2Strings (getLastWord(), _word ) );
       
        
        wordTab.push(_word);
        //wordTab.push("Hello World");
        
        curIndex+=1 ; // voir si je le garde ... 
        
        // gamers[msg.sender] = 1;
        // option plus générale : incrémenter le nb de jeux : 
        
        //gamers[msg.sender] = 1; // cas où mapping adr n'existe pas : 
        gamers[msg.sender]+=1;
        
        // check jackpot !
        // bool success; 
        output = "checking your word  ";
    
        
        bool wordOK = checkWord(_word);
        if (wordOK) {
            
                output = "COOL you got the Word- You are the winner ";
                state = State.Ended; // end game : 
        }
        
        return output; // "Goodbye" par défaut 
    }
    
    function getLastWord() public view returns (string memory) {
        
        // return wordTab[curIndex]; // _index for last word in gameTab
        // OR 
        return wordTab[wordTab.length - 1];
    }
    /**
    function getLastWord(uint _index) public view returns(string){
        return wordTab[_index]; // _index for last word in gameTab
    }
    */
    
    function checkWord(string memory _word) public returns (bool) {
        
        // return par défaut : false 
        bool success; // default is false 
        //string last;
        //last = getLastWord();
        // comparer les 2 mots :
        // if (wordTab[0] == getLastWord())
        // if ( _word == firstWord ) { // var memory == var storage 
        string memory first = wordTab[0]; // OR  firstWord
        
        // output = "Hello- checking word "; // "Goodbye" par défaut 
        success = compare2Strings (first, _word );
        if (success ) {   // pour tester ... le 5emme gagne ! 
            
            theWinner = msg.sender;
            //State of game to Ended 
            
            //  event ended 
            emit ended (true);
            output = "COOL your Word checked successfully "; 
            // utile si fct appelée en autonome sinon peut être supprimé - fait dans la fct appelante: addWord 
        }
        
        // _word = wordTab[wordTab.length]; 
        // comparer 2 chaines : ... 
        // if ( _word == first ) { -- ne fonctionne pas }
        // if ( _word == 'Hello' ) {   // pour tester ... 
        /**
        if ( wordTab.length == 5 ) {   // pour tester ... le 5emme gagne ! 
            success = true;
        
        theWinner = msg.sender;
        
        //  event ended 
        emit ended(true);
        }
        */
        
        return success;
        
    }
    
    /**
    function getWinner() external view returns (address) {
        
        require(theWinner != '', "No Winner yet");
        return theWinner;
    }
    */
    
    
    function getChampion() public view returns (address) {
        
        // require(theWinner != '', "No Winner yet");
        
        return theWinner;
    }
    
    function set_admin(address _newAdmin) public {
        gameAdmin = _newAdmin;
        // return gameAdmin; 
        
    }
    

    function compare2Strings(string memory _s1, string memory _s2) internal pure returns (bool) {
        if(bytes(_s1).length != bytes(_s2).length) {
            return false;
        } else {
            bytes32 hashS1 = keccak256(abi.encodePacked(_s1));
            bytes32 hashS2 = keccak256(abi.encodePacked(_s2));
            return hashS1 == hashS2;
            // return keccak256(_s1) == keccak256(_s2); // ne fonctionne pas ! 
        }
    }
    
}
