[9:57 am, 29/10/2023] Disha Satani: thodu
[10:06 am, 29/10/2023] Disha Satani: // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DroneManagement {
    address public owner;
    mapping(address => bool) public authorizedUsers;

    struct Drone {
        string name;
        address owner;
        bool active;
        string data; // Store data for each drone
    }

    Drone[] public drones;
    mapping(address => string) public dataCenters;
    mapping(address => string) public dataCenterData;

    event DroneAdded(string name, address owner);
    event DroneActivated(string name);
    event DroneDeactivated(string name);
    event DroneDataUpdated(string name, string data);
    event DataCenterAdded(address dataCenter);
    event DataSent(address fromDataCenter, address toDataCenter, string data);
    event DataCenterDataUpdated(address dataCenter, string data);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedUsers[msg.sender] = true;
    }

    function authorizeUser(address user) public onlyOwner {
        authorizedUsers[user] = true;
    }

    function revokeAuthorization(address user) public onlyOwner {
        authorizedUsers[user] = false;
    }

    function addDrone(string memory name) public {
        require(authorizedUsers[msg.sender], "User is not authorized to add a drone.");

        drones.push(Drone(name, msg.sender, true, ""));
        emit DroneAdded(name, msg.sender);
    }

    function activateDrone(uint256 index) public {
        require(index < drones.length, "Drone does not exist.");
        require(drones[index].owner == msg.sender, "Only the owner can activate the drone.");

        drones[index].active = true;
        emit DroneActivated(drones[index].name);
    }

    function deactivateDrone(uint256 index) public {
        require(index < drones.length, "Drone does not exist.");
        require(drones[index].owner == msg.sender, "Only the owner can deactivate the drone.");

        drones[index].active = false;
        emit DroneDeactivated(drones[index].name);
    }

    function updateDroneData(uint256 index, string memory newData) public {
        require(index < drones.length, "Drone does not exist.");
        require(drones[index].owner == msg.sender, "Only the owner can update drone data.");

        drones[index].data = newData;
        emit DroneDataUpdated(drones[index].name, newData);
    }

    function addDataCenter(string memory dataCenterName) public {
        dataCenters[msg.sender] = dataCenterName;
        emit DataCenterAdded(msg.sender);
    }

    function sendDataToDataCenter(address toDataCenter, string memory data) public {
        require(bytes(dataCenters[msg.sender]).length > 0, "Sender is not a registered data center.");
        require(bytes(dataCenters[toDataCenter]).length > 0, "Recipient is not a registered data center.");

        // Append the sent data to the recipient data center's existing data
        dataCenterData[toDataCenter] = string(abi.encodePacked(dataCenterData[toDataCenter], data));

        emit DataSent(msg.sender, toDataCenter, data);
        emit DataCenterDataUpdated(toDataCenter, dataCenterData[toDataCenter]);
    }

    function sendDataFromDroneToDataCenter(uint256 droneIndex, address toDataCenter, string memory data) public {
        require(droneIndex < drones.length, "Drone does not exist.");
        require(drones[droneIndex].owner == msg.sender, "Only the drone owner can send data.");
        require(bytes(dataCenters[toDataCenter]).length > 0, "Recipient is not a registered data center.");

        // Append the sent data to the recipient data center's existing data
        dataCenterData[toDataCenter] = string(abi.encodePacked(dataCenterData[toDataCenter], data));

        emit DataSent(msg.sender, toDataCenter, data);
        emit DataCenterDataUpdated(toDataCenter, dataCenterData[toDataCenter]);
    }

    function getDroneCount() public view returns (uint256) {
        return drones.length;
    }

    function getDroneData(uint256 index) public view returns (string memory) {
        require(index < drones.length, "Drone does not exist.");
        return drones[index].data;
    }

    function getDataCenterName(address dataCenterAddress) public view returns (string memory) {
        return dataCenters[dataCenterAddress];
    }

    function getDataCenterData(address dataCenterAddress) public view returns (string memory) {
        return dataCenterData[dataCenterAddress];
    }

    function updateDataCenterData(string memory newData) public {
        dataCenterData[msg.sender] = newData;
        emit DataCenterDataUpdated(msg.sender, newData);
    }
}