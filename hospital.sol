// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HospitalManagement {
    address public admin; // Admin of the hospital contract

    enum Gender { Male, Female, Other }

    struct Patient {
        uint256 patientId;
        string name;
        uint256 age;
        Gender gender;
        bool admitted;
        uint256 bedNumber;
        uint256 admissionDate;
        uint256 dischargeDate;
    }

    mapping(address => Patient) public patients; // Mapping from patient address to Patient
    uint256 public totalPatients;
    
    event PatientAdmitted(address indexed patientAddress, uint256 indexed patientId, string name, uint256 admissionDate);
    event PatientDischarged(address indexed patientAddress, uint256 indexed patientId, string name, uint256 dischargeDate);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function admitPatient(
        address _patientAddress,
        string memory _name,
        uint256 _age,
        Gender _gender,
        uint256 _bedNumber
    ) external onlyAdmin {
        totalPatients++;
        patients[_patientAddress] = Patient({
            patientId: totalPatients,
            name: _name,
            age: _age,
            gender: _gender,
            admitted: true,
            bedNumber: _bedNumber,
            admissionDate: block.timestamp,
            dischargeDate: 0
        });

        emit PatientAdmitted(_patientAddress, totalPatients, _name, block.timestamp);
    }

    function dischargePatient(address _patientAddress) external onlyAdmin {
        require(patients[_patientAddress].admitted, "Patient is not admitted");
        
        patients[_patientAddress].admitted = false;
        patients[_patientAddress].dischargeDate = block.timestamp;

        emit PatientDischarged(_patientAddress, patients[_patientAddress].patientId, patients[_patientAddress].name, block.timestamp);
    }

    function getPatientDetails(address _patientAddress)
        external
        view
        returns (
            uint256 patientId,
            string memory name,
            uint256 age,
            Gender gender,
            bool admitted,
            uint256 bedNumber,
            uint256 admissionDate,
            uint256 dischargeDate
        )
    {
        Patient storage patient = patients[_patientAddress];
        return (
            patient.patientId,
            patient.name,
            patient.age,
            patient.gender,
            patient.admitted,
            patient.bedNumber,
            patient.admissionDate,
            patient.dischargeDate
        );
    }
}
