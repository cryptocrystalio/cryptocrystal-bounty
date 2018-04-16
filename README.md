# The CryptoCrystal Bug Bounty Program 

Thank you everyone for your participation!!
We recognize the importance of security researchers in keeping our community and decentralized application safe and fun. 
With the launch of CryptoCrystal , we would love the community to help provide disclosure of security vulnerabilities via our bounty program described below.



## What you Should Know About CryptoCrystals:

CryptoCrystal is a decentralized application hosted on the Ethereum.
CryptoCrystals are sentient Shiny Crystals that have personalities similar to human while being overly cute like pet animals.

Each of them is unique in the Ethereum Network, with no duplicated DNA structure. Players can have fun by Mine, Trade, and Breed the Crystals.

CryptoCrystal guarantees Unique Digital Scarcity by the smart contract.In CryptoCrystal, the amount of Crystal reserve, and discovery possibility is all determined by the smart contract. In addition to giving each crystals unique DNA Gene, its uniqueness and invulnerability is also provided by the Block chain.With this, whoever is trying to use the Crystals in an application can confirm their rarity without being hidden.With respect to how Bitcoin was created in 2008, the general discovery rate and the amount of mineral reserve are provided as in the following image.

![alt](https://cdn-images-1.medium.com/max/1600/1*0iNyqlenha-Ja1RnilTE0w.png)


*CryptoCrystal* is built on the Ethereum network; ether will be necessary to fuel transactions, which include mining, trading, and melting CryptoCrystals.

For the purpose of this bounty program, the program will run within the Rinkeby test network. Also the source code will be available for review.

https://rinkeby.etherscan.io/address/0x0945884e5ccb5c5bc977a6c49e87bc72c9a77f44#code

CryptoCrystal is mined with the transaction of Pickaxes(ERC20 Token).More than Two CryptoCrystals can be melted as a new CryptoCrystal. 

### See full basic operations here

https://github.com/cryptocrystalio/cryptocrystal-bounty/blob/master/basic.md


## The Scope for this Bounty Program:

This bounty program will run within the Rinkeby network from  08:00 GMT April 16th -08:00 GMT April 21th, 2018. All code important to this bounty program is publicly available within this repo Help us identify bugs, vulnerabilities, and exploits in the smart contract such as:

Breaking the game (ex. trading doesn’t work, mining doesn’t work,)
Incorrect usage of the game and the possibility.
Steal a crystal from someone else
Act as one of the admin accounts
Complete something without Pickaxes or Ether.
Steal a eth from admin
Any sort of malfunction


## Rules & Rewards:

Issues that have already been submitted by another user or are already known to the CryptoCrystal team are not eligible for bounty rewards.

Bugs and vulnerabilities should only be found using accounts you own and create. Please respect third party applications and understand that an exploit that is not specific to the CryptoCrystal smart contract is not part of the bounty program. Attacks on the network that result in bad behaviour are not allowed.

The CryptoCrystal website is not part of the bounty program, only the smart contract code included in this repo.The CryptoCrystal bounty program considers a number of variables in determining rewards. Determinations of eligibility, score and all terms related to a reward are at the sole and final discretion of CryptoCrystal team.Reports will only be accepted via GitHub issues submitted to this repo.
In general, please investigate and report bugs in a way that makes a reasonable, good faith effort not to be disruptive or harmful to us or others.

The value of rewards paid out will vary depending on Severity which is calculated based on Impact and Likelihood as followed by OWASP:

*Note: Rewards are at the sole discretion of the CryptoCrystal Team. 1 point currently corresponds to 1 stake (paid in Pkx : All 50,000 Pkx = 250Eth)

Critical: up to 1000 points
High: up to 500 points
Medium: up to 250 points
Low: up to 125 points
Note: up to 50 points

### Examples of Impact:

High: Steal a crystal from someone, steal/redirect ETH or crystals or Pkx to another address, set crystal genes to arbitrary value, block actions for all users or some non-trivial fraction of users, create a crystal without mining.
Gas Limit and Loops.

Medium: Break mining rules (no-randomizing,by-pass randomizing), lock a single crystal owned by an address you don't control, manipulate the trade. Charge so high Gas fee with which user cannot play CryptoCrystal.

Low: Block a user from the exchange, create comission errors in exchanges, cancel or block another user's exhibit.

Suggestions for Getting the Highest Score:

Description: Be clear in describing the vulnerability or bug. Ex. share code scripts, screenshots or detailed descriptions.

Fix it: if you can suggest how we fix this issue in an appropriate manner, higher points will be rewarded.

### CryptoCrystal appreciates you taking the time to participate in our program, which is why we’ve created rules for us too:

We will respond as quickly as we can to your submission (within 3 days).
Let you know if your submission will qualify for a bounty (or not) within 7 business days.

We will keep you updated as we work to fix the bug you submitted.
CryptoCrystal' core development team, employees and all other people paid by the CryptoCrystal project, are not eligible for rewards.

### How to Create a Good Vulnerability Submission:

Description: A brief description of the vulnerability
Scenario: A description of the requirements for the vulnerability to happen
Impact: The result of the vulnerability and what or who can be affected
Reproduction: Provide the exact steps on how to reproduce this vulnerability on a new contract, and if possible, point to specific tx hashes or accounts used.
Note: If we can't reproduce with given instructions then a (Truffle) test case will be required.
Fix: If applies, what would would you do to fix this


## FAQ:

#### How are the bounties paid out?

Rewards are paid out in Pkx after the submission has been validated, usually a few days later. Please provide your ETH address.
I reported an issue but have not received a response!
We aim to respond to submissions as fast as possible. Feel free to email us if you have not received a response.
support@cryptocrystal.io

#### Can I use this code elsewhere?
No. Please do not copy this code for other purposes than reviewing it.

#### I have more questions!
Create a new issue with the title starting as “QUESTION”

#### Will the code change during the bounty?
Yes, as issues are reported we will update the code as soon as possible. 
Please make sure your bugs are reported against the latest versions of the published code.

#### I'm having trouble setting up the contracts?
Join the CryptoCrystal Gitter to get some assistance

## Important Legal Information:

The bug bounty program is an experimental rewards program for our community to encourage and reward those who are helping us to improve CryptoCrystals. You should know that we can close the program at any time, and rewards are at the sole discretion of the CryptoCrystal team. 

All rewards are subject to applicable law and thus applicable taxes. Don't target our physical security measures, or attempt to use social engineering, spam, distributed denial of service (DDOS) attacks, etc. Lastly, your testing must not violate any law or compromise any data that is not yours.

Copyright (c) 2018 Quan, Inc. 

All rights reserved. The contents of this repository is provided for review and educational purposes ONLY. You MAY NOT use, copy, distribute, or modify this software without express written permission from Quan, inc. 
