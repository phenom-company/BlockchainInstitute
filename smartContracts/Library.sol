pragma solidity ^0.4.14;

contract Library {
  address constant nullAddress = 0x0;

  mapping(address => mapping(uint => address)) public articlesOfAuthor;
  mapping(address => mapping(uint => address)) public reviewersOfArticle;

  mapping(address => address) public authorOfArticle;

  mapping(address => uint) public reviewerRating;
  mapping(address => uint) public articleRating;
  mapping(address => uint) public reviewerVotes;
  mapping(address => uint) public articleVotes;
  mapping(address => uint) public experience; // experience of reviewer

  mapping(address => bool) public addressIsArticle;
  mapping(address => bool) public banned; // address which were banned by manager

  address manager = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;

  modifier _managerOnly { require(msg.sender == manager); _; }
  modifier _articleOnly { require(addressIsArticle[msg.sender]); _; }

  function changeRatingOfReviewer(address reviewer, uint rating) external _articleOnly {
      require(rating < 100);
      uint newRating;
      if(reviewerVotes[reviewer] == 0) {
        newRating = rating;
      } else {
        newRating = (reviewerRating[reviewer] + rating) / 2;
      }
      reviewerRating[reviewer] = newRating;
  }

  function changeRatingOfArticle(uint rating) external _articleOnly {
      require(rating < 100);
      uint newRating;
      if(articleVotes[msg.sender] == 0) {
        newRating = rating;
      } else {
        newRating = (articleRating[msg.sender] + rating) / 2;
      }
      articleRating[msg.sender] = newRating;
  }

  function addArticle(address author, address article) external _managerOnly {
      require(!addressIsArticle[article]);
      addressIsArticle[article] = true;
      uint i = 0;
      while(articlesOfAuthor[author][i] != nullAddress) {
        i++;
      }
      authorOfArticle[article] = author;
      articlesOfAuthor[author][i] = article;
  }

  function deleteArticle(address author, address article) external _managerOnly {
      require(addressIsArticle[article]);
      require(authorOfArticle[article] == author);
      addressIsArticle[article] = false;
      uint i = 0;
      while(articlesOfAuthor[author][i] != article) {
        i++;
      }
      authorOfArticle[article] = nullAddress;
      articlesOfAuthor[author][i] = nullAddress;
  }

  function addReviewer(address reviewer) external _articleOnly {
      uint i = 0;
      while(reviewersOfArticle[msg.sender][i] != nullAddress) {
        i++;
      }
      reviewersOfArticle[msg.sender][i] = reviewer;
  }

  function deleteReviewer(address article, address reviewer) external _articleOnly {
      uint i = 0;
      while(reviewersOfArticle[article][i] != reviewer) {
        i++;
      }
      reviewersOfArticle[article][i] = nullAddress;
  }

  function banAddress(address breaker) external _managerOnly {
      require(!banned[breaker]);
      banned[breaker] = true;
  }

  function returnStatus(address user) external returns(bool)  {
      return banned[user];
  }

  function returnExperience(address reviewer) external returns(uint) {
      return experience[reviewer];
  }

  function addExperience(address reviewer, uint value) external _articleOnly {  //function that adds points of experience
      experience[reviewer] += value;
  }

}
