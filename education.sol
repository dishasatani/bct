// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducationSystem {
    address public admin; // Admin of the education system

    enum CourseStatus { Pending, Active, Completed }

    struct Course {
        uint256 courseId;
        string courseName;
        uint256 enrollmentFee;
        CourseStatus status;
    }

    mapping(uint256 => Course) public courses; // Mapping from course ID to Course
    uint256 public totalCourses;
    
    event CourseCreated(uint256 indexed courseId, string courseName, uint256 enrollmentFee);
    event CourseStatusUpdated(uint256 indexed courseId, CourseStatus status);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createCourse(string memory _courseName, uint256 _enrollmentFee) external onlyAdmin {
        totalCourses++;
        courses[totalCourses] = Course({
            courseId: totalCourses,
            courseName: _courseName,
            enrollmentFee: _enrollmentFee,
            status: CourseStatus.Pending
        });

        emit CourseCreated(totalCourses, _courseName, _enrollmentFee);
    }

    function updateCourseStatus(uint256 _courseId, CourseStatus _status) external onlyAdmin {
        require(_courseId <= totalCourses && _courseId > 0, "Invalid course ID");

        courses[_courseId].status = _status;

        emit CourseStatusUpdated(_courseId, _status);
    }

    function getCourseDetails(uint256 _courseId)
        external
        view
        returns (
            uint256 courseId,
            string memory courseName,
            uint256 enrollmentFee,
            CourseStatus status
        )
    {
        Course storage course = courses[_courseId];
        return (course.courseId, course.courseName, course.enrollmentFee, course.status);
    }
}
