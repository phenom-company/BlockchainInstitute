pragma solidity ^0.4.10;

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



contract Article{
    // Fields which Yaro need to feel before deployment
    address constant LibraryAddress = 0xec5bee2dbb67da8757091ad3d9526ba3ed2e2137;

    uint public constant maxReviewersCount = 5;
    uint public constant minConfirmationsCount = 4;
    uint public constant neededExperience = 100; //experiece of reviewer that is neccesary to get opportunity to free review
    uint public constant reviewPrice = 7000000; //price that should be paid in case of lack of experience
    uint public constant experienceValue = 10; //experience points reviewer will get

    address constant nullAddress = 0x0;

    uint constant numerator = 10; // 10 percents of profit that reviewer will get
    uint constant denominator = 100;

    address public addressAuthor;

    string public title;
    string public author;

    uint public articlePrice;
    uint public publicationDate; // current tmstp in ms

    bool confirmed = false; //// initially we setting not confirmed status for article

    address[5] public reviewersAddresses;

    uint public reviewersCount = 0;
    uint public passedReviews = 0;

    Library public lib = Library(LibraryAddress);

    mapping(address => bool) public addressIsReviewer;
    mapping(address => bool) public addressIsBuyer;
    mapping(address => bool) public madeConfirmation;

    mapping(address => string) public reviewersPubKeys;
    mapping(address => string) public reviewersDownloadLinks;
    mapping(address => string) public reviewsLinks;
    mapping(address => string) public buyersPubKeys;
    mapping(address => string) public buyersDownloadLinks;

    mapping(address => uint) public timeStamps; //timestamp when address became reviewer
    mapping(address => uint) public reward; //reward to reviewer


    // Modifiers
    modifier _reviewerOnly { require(addressIsReviewer[msg.sender]); _; }
    modifier _authorOnly { require(msg.sender == addressAuthor); _; }
    modifier _buyerOnly { require(addressIsBuyer[msg.sender]); _; }


    function Article(string _title, string _author, uint _articlePrice) public {
        addressAuthor = msg.sender;
        title = _title;
        author = _author;
        articlePrice = _articlePrice;
        publicationDate = now;
    }

    function becomeReviewer (string pubkey) external payable{
        require(!lib.returnStatus(msg.sender));
        require(!addressIsReviewer[msg.sender]);
        require(reviewersCount < maxReviewersCount);
        uint experience = lib.returnExperience(msg.sender);
        if(experience < neededExperience) {
          require(msg.value > reviewPrice);
        }
        addressIsReviewer[msg.sender] = true;
        reviewersAddresses[reviewersCount] = msg.sender;
        reviewersCount += 1;
        reviewersPubKeys[msg.sender] = pubkey;
        lib.addReviewer(msg.sender);
        timeStamps[msg.sender] = now;
    }

    function deleteReviewer (address reviewer) external _authorOnly {
        require(addressIsReviewer[reviewer]);
        require(timeStamps[reviewer] + 5 days < now);
        require(!madeConfirmation[reviewer]);
        addressIsReviewer[reviewer] = false;
        reviewersCount -= 1;
        lib.deleteReviewer(this, reviewer);
        lib.changeRatingOfReviewer(reviewer, 0);
    }

    function confirm (bool resolution, string reviewLink) external _reviewerOnly {
        require(!madeConfirmation[msg.sender]);
        if (resolution) {
            passedReviews += 1;
            if (passedReviews == minConfirmationsCount){
              confirmed = true;
            }

        }
        madeConfirmation[msg.sender] = true;
        reviewsLinks[msg.sender] = reviewLink;
        lib.addExperience(msg.sender, experienceValue);
    }

    function buy (string pubkey) external payable {
        require(confirmed);
        require(msg.value >= articlePrice);
        addressIsBuyer[msg.sender] = true;
        buyersPubKeys[msg.sender] = pubkey;
        uint i;
        for(i = 0; i < 5; i++) {
          reward[reviewersAddresses[i]] = msg.value * numerator / denominator;
        }
    }

    function changeRatingOfArticle(uint rating) external _buyerOnly {
        lib.changeRatingOfArticle(rating);
    }

    function changeRatingOfReviewer(address reviewer, uint rating) external _buyerOnly {
        require(addressIsReviewer[reviewer]);
        lib.changeRatingOfReviewer(reviewer, rating);
    }

    function addBuyerDownloadLink (address buyerAddress, string ipfsLink) external _authorOnly {
        require(addressIsBuyer[buyerAddress]);
        buyersDownloadLinks[buyerAddress] = ipfsLink;
    }

    function addReviewerDownloadLink (address reviewerAddress, string ipfsLink) external _authorOnly {
        require(addressIsReviewer[reviewerAddress]);
        reviewersDownloadLinks[reviewerAddress] = ipfsLink;
    }

    function claimReward() external _reviewerOnly {
        require(reward[msg.sender] > 0);
        uint value = reward[msg.sender];
        reward[msg.sender] = 0;
        msg.sender.transfer(value);
    }

}
