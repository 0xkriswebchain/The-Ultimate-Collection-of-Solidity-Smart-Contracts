// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DAO {
    struct Investor {
        uint256 shares;
        bool voted;
    }

    struct Proposal {
        string description;
        uint256 amount;
        address payable recipient;
        uint256 voteCount;
        uint256 endTime;
        bool executed;
    }

    mapping(address => Investor) public investors;
    Proposal[] public proposals;
    address[] public investorList;
    uint256 public totalShares;
    uint256 public availableFunds;
    uint256 public contributionTimeEnd;
    uint256 public voteTime;
    uint256 public quorum;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyDuringContribution() {
        require(block.timestamp <= contributionTimeEnd, "Contribution time has ended");
        _;
    }

    modifier onlyDuringVoting(uint256 proposalId) {
        require(block.timestamp <= proposals[proposalId].endTime, "Voting time has ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function initializeDAO(
        uint256 _contributionTimeEnd,
        uint256 _voteTime,
        uint256 _quorum
    ) public onlyOwner {
        require(_contributionTimeEnd > 0, "Contribution time must be greater than zero");
        require(_voteTime > 0, "Vote time must be greater than zero");
        require(_quorum > 0 && _quorum <= 100, "Quorum must be between 1 and 100");

        contributionTimeEnd = block.timestamp + _contributionTimeEnd;
        voteTime = _voteTime;
        quorum = _quorum;
    }

    function contribution() public payable onlyDuringContribution {
        require(msg.value > 0, "Contribution must be greater than zero");
        if (investors[msg.sender].shares == 0) {
            investorList.push(msg.sender);
        }
        investors[msg.sender].shares += msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }

    function redeemShare(uint256 amount) public {
        require(investors[msg.sender].shares >= amount, "Not enough shares");
        require(availableFunds >= amount, "Not enough funds");
        investors[msg.sender].shares -= amount;
        totalShares -= amount;
        availableFunds -= amount;
        payable(msg.sender).transfer(amount);
    }

    function transferShare(uint256 amount, address to) public {
        require(investors[msg.sender].shares >= amount, "Not enough shares");
        if (investors[to].shares == 0) {
            investorList.push(to);
        }
        investors[msg.sender].shares -= amount;
        investors[to].shares += amount;
    }

    function createProposal(
        string calldata description,
        uint256 amount,
        address payable recipient
    ) public onlyOwner {
        require(availableFunds >= amount, "Not enough funds");
        proposals.push(
            Proposal({
                description: description,
                amount: amount,
                recipient: recipient,
                voteCount: 0,
                endTime: block.timestamp + voteTime,
                executed: false
            })
        );
    }

    function voteProposal(uint256 proposalId) public onlyDuringVoting(proposalId) {
        require(investors[msg.sender].shares > 0, "No shares to vote with");
        require(!investors[msg.sender].voted, "Already voted");
        proposals[proposalId].voteCount += investors[msg.sender].shares;
        investors[msg.sender].voted = true;
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");
        require(
            proposal.voteCount >= (totalShares * quorum) / 100,
            "Quorum not reached"
        );
        proposal.executed = true;
        availableFunds -= proposal.amount;
        proposal.recipient.transfer(proposal.amount);
    }

    function proposalList()
        public
        view
        returns (
            string[] memory,
            uint256[] memory,
            address[] memory
        )
    {
        string[] memory descriptions = new string[](proposals.length);
        uint256[] memory amounts = new uint256[](proposals.length);
        address[] memory recipients = new address[](proposals.length);

        for (uint256 i = 0; i < proposals.length; i++) {
            descriptions[i] = proposals[i].description;
            amounts[i] = proposals[i].amount;
            recipients[i] = proposals[i].recipient;
        }

        return (descriptions, amounts, recipients);
    }

    function allInvestorList() public view returns (address[] memory) {
        return investorList;
    }
}