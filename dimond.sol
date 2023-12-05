// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiamondRegistry {
    address public owner; // Owner of the contract

    enum DiamondStatus { Listed, Sold }

    struct Diamond {
        address owner; // Current owner of the diamond
        string certification; // Certification details of the diamond
        uint256 price; // Price of the diamond in wei
        DiamondStatus status; // Status of the diamond
    }

    mapping(uint256 => Diamond) public diamonds; // Mapping from diamond ID to Diamond
    uint256 public diamondIdCounter; // Counter for diamond IDs

    event DiamondListed(uint256 indexed diamondId, address indexed owner, uint256 price);
    event DiamondSold(uint256 indexed diamondId, address indexed buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier diamondExists(uint256 diamondId) {
        require(diamonds[diamondId].owner != address(0), "Diamond does not exist");
        _;
    }

    modifier diamondForSale(uint256 diamondId) {
        require(diamonds[diamondId].status == DiamondStatus.Listed, "Diamond is not for sale");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function listDiamond(uint256 _price) external onlyOwner {
        uint256 diamondId = diamondIdCounter++;
        diamonds[diamondId] = Diamond({
            owner: owner,
            certification: "", // You can initialize this as an empty string or modify as needed.
            price: _price,
            status: DiamondStatus.Listed
        });

        emit DiamondListed(diamondId, owner, _price);
    }

    function buyDiamond(uint256 diamondId) external payable diamondExists(diamondId) diamondForSale(diamondId) {
        Diamond storage diamond = diamonds[diamondId];
        require(msg.value >= diamond.price, "Insufficient funds");

        // Transfer funds to the diamond owner
        payable(diamond.owner).transfer(msg.value);

        // Update diamond ownership and status
        diamond.owner = msg.sender;
        diamond.status = DiamondStatus.Sold;

        emit DiamondSold(diamondId, msg.sender);
    }

    function getDiamondDetails(uint256 diamondId)
        external
        view
        diamondExists(diamondId)
        returns (address diamondOwner, string memory certification, uint256 price, DiamondStatus status)
    {
        Diamond storage diamond = diamonds[diamondId];
        return (diamond.owner, diamond.certification, diamond.price, diamond.status);
    }
}
