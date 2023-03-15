// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }

    
    mapping(address => uint256)[] public bets;
    mapping(uint => Quiz_item) public quizs; //arr
    mapping(address=>uint256) public balances;

    address public owner;
    uint public vault_balance;
    uint private quizCnt; // quiz cnt
    

    constructor () {
        owner=msg.sender;

        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender==owner);
        quizs[q.id]=q;
        quizCnt+=1;
    }

    function getAnswer(uint quizId) public view returns (string memory){
        require(msg.sender==owner);
        return quizs[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory quiz = quizs[quizId];
        quiz.answer="";
        return quiz;
    }

    function getQuizNum() public view returns (uint){
        return quizCnt;
    }
    
    function betToPlay(uint quizId) public payable {
        Quiz_item memory quiz=quizs[quizId];
        uint256 amount=msg.value;

        require(amount>=quiz.min_bet);
        require(amount<=quiz.max_bet);
        
        uint index=quizId-1;
        bets.push();
        bets[index][msg.sender]+=amount;
        
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        uint index=quizId-1;
        if(keccak256(bytes(quizs[quizId].answer))==keccak256(bytes(ans))){
            balances[msg.sender] += quizs[quizId].min_bet * 2;
            return true;
        }
        else {
            vault_balance+=bets[index][msg.sender];
            bets[index][msg.sender]=0;
            return false;
        }
    }

    function claim() public {
        uint256 amount=balances[msg.sender]; //prev
        balances[msg.sender] = 0; // 더하기 불가
        payable(msg.sender).transfer(amount);
    }
    receive() external payable {
    }


}
