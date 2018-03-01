# Smart contracts for Article system
This concept was developed during hackathon arranged by [Blockchain Institute][institute]. The main task was to create blockchain-based system that provides two items:
- Peer review of scientific articles that allows distribution of reward among reviewers and confirmation of quality of the review
- Providing reward to authors of articles

## Overview
The solution is based on Ethereum blockchain. It includes main contract Library that contains information about all authors, articles, reviewers and their ratings. For each article new smart contract is deployed which provides interaction between author, reviewers, buyers of the article and also applies to Library saving important information.
The whole idea was to create service that would have simple interface, realize deploy of article contract and allow users to interact with it and send transactions to smart contract signing them through [Metamask][metamask] or another way. Also reviewers, buyers would have access to article by dint of individual [IPFS][ipfs] link.

## Description of Library smart contract
The contract keeps the whole information about system and is run by special address - Manager.

#### Functions of Library

**changeRatingOfReviewer**
```cs
function changeRatingOfReviewer(uint rating, address reviewer) external _articleOnly
```
allows article to change rating of reviewer((this function in article smart contract is executed by buyers))

**changeRatingOfArticle**
```cs
function changeRatingOfArticle(uint rating) external _articleOnly
```
allows article to change rating of article (this function in article smart contract is executed by buyers)

**addArticle**
```cs
function addArticle(address author, address article) external _managerOnly
```
allows Manager to add article which can interact with Library

**deleteArticle**
```cs
function deleteArticle(address author, address article) external _managerOnly
```
allows Manager to forbid article to interact with Library

**addReviewer**
```cs
function addReviewer(address reviewer) external _articleOnly
```
allows article to remember addresses which review this article

**deleteReviewer**
```cs
function deleteReviewer(address article, address reviewer) external _articleOnly
```
allows article to delete reviewers who didn't fulfill obligations

**banAddress**
```cs
function banAddress(address breaker) external _managerOnly
```
allows Manager to ban addresses which broke the rules

**returnStatus**
```cs
function returnStatus(address user) external returns(bool)
```
returns ban status

**returnExperience**
```cs
function returnExperience(address reviewer) external returns(uint)
```
return reviewer's experience

**addExperience**
```cs
function addExperience(address reviewer, uint value) external _articleOnly
```
allow function from article smart contract to add experience points

## Description of Article smart contract
Each article has individual smart contract which contains info about author, title, price, date of publication and etc. It permits peer review, buying of article by dint of [IPFS][ipfs].

#### Functions of Article

**becomeReviewer**
```cs
function becomeReviewer (string pubkey) external payable
```
allows address to become reviewer for payment or free(depends on experience)

**deleteReviewer**
```cs
function deleteReviewer (address reviewer) external _authorOnly
```
allows author to delete reviewer if he didn't fulfill obligations in time. Rating of reviewer becomes lower

**confirm**
```cs
function confirm (bool resolution, string reviewLink) external _reviewerOnly
```
allow reviewer to load review link and give permission for selling of refuse

**buy**
```cs
function buy (string pubkey) external payable
```
if article gets necessary number of confirmations, users can buy article using this function

**changeRatingOfArticle**
```cs
function changeRatingOfArticle(uint rating) external _buyerOnly
```
applies to Library and changes rating of article

**changeRatingOfReviewer**
```cs
function changeRatingOfReviewer(address reviewer, uint rating) external _buyerOnly
```
applies to Library and changes rating of article

**addBuyerDownloadLink**
```cs
function addBuyerDownloadLink (address buyerAddress, string ipfsLink) external _authorOnly
```
allows to add ipfs link for buyers

**addReviewerDownloadLink**
```cs
function addReviewerDownloadLink (address reviewerAddress, string ipfsLink) external _authorOnly
```
allows to add ipfs link for reviewer

**claimReward**
```cs
function claimReward() external _reviewerOnly
```
allows reviewer to get their reward

[institute]: https://blockchaininstitute.io/
[metamask]: https://metamask.io/
[ipfs]: https://ipfs.io/

## Collaborators

* **[Alex Smirnov](https://github.com/AlekseiSmirnov)**
* **[Dmitriy Pukhov](https://github.com/puhoshville)**
* **[Kate Krishtopa](https://github.com/Krishtopa)**
* **[Yaroslav Artyukh](https://github.com/artyukh)**
* **[Vladislav Shentyapin](https://github.com/lShinal)**
