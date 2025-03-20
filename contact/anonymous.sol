// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Fundraiser {

    struct Campaign {
        address creator;
        string title;
        string description;
        uint256 goal;
        uint256 amountRaised;
        bool active;
    }

    Campaign[] public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event CampaignCreated(uint256 indexed campaignId, address creator, string title, uint256 goal);
    event DonationReceived(uint256 indexed campaignId, address donor, uint256 amount);
    event CampaignClosed(uint256 indexed campaignId, uint256 totalAmountRaised);

    /// @notice Create a new fundraising campaign
    function createCampaign(string memory _title, string memory _description, uint256 _goal) public {
        require(_goal > 0, "Goal must be greater than zero");

        campaigns.push(Campaign({
            creator: msg.sender,
            title: _title,
            description: _description,
            goal: _goal,
            amountRaised: 0,
            active: true
        }));

        emit CampaignCreated(campaigns.length - 1, msg.sender, _title, _goal);
    }

    /// @notice Donate to a fundraising campaign
    function donate(uint256 _campaignId) public payable {
        require(_campaignId < campaigns.length, "Invalid campaign ID");
        Campaign storage campaign = campaigns[_campaignId];

        require(campaign.active, "Campaign is not active");
        require(msg.value > 0, "Donation must be greater than zero");

        campaign.amountRaised += msg.value;
        contributions[_campaignId][msg.sender] += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    /// @notice Close the campaign once the goal is reached or manually
    function closeCampaign(uint256 _campaignId) public {
        require(_campaignId < campaigns.length, "Invalid campaign ID");
        Campaign storage campaign = campaigns[_campaignId];

        require(msg.sender == campaign.creator, "Only the creator can close the campaign");
        require(campaign.active, "Campaign is already closed");

        campaign.active = false;

        emit CampaignClosed(_campaignId, campaign.amountRaised);
    }

    /// @notice Withdraw funds to the creator's wallet
    function withdrawFunds(uint256 _campaignId) public {
        require(_campaignId < campaigns.length, "Invalid campaign ID");
        Campaign storage campaign = campaigns[_campaignId];

        require(msg.sender == campaign.creator, "Only the creator can withdraw funds");
        require(!campaign.active, "Campaign must be closed first");
        require(campaign.amountRaised > 0, "No funds to withdraw");

        uint256 amount = campaign.amountRaised;
        campaign.amountRaised = 0;
        payable(campaign.creator).transfer(amount);
    }

    /// @notice Get the details of a specific campaign
    function getCampaign(uint256 _campaignId) public view returns (
        address, string memory, string memory, uint256, uint256, bool
    ) {
        require(_campaignId < campaigns.length, "Invalid campaign ID");
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.creator,
            campaign.title,
            campaign.description,
            campaign.goal,
            campaign.amountRaised,
            campaign.active
        );
    }

    /// @notice Get the total number of campaigns
    function getTotalCampaigns() public view returns (uint256) {
        return campaigns.length;
    }
}
