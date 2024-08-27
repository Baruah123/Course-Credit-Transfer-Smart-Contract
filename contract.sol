// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CourseCreditTransfer {
    // Structure to represent a Course
    struct Course {
        string courseName;
        uint credits;
        bool exists;
    }

    // Structure to represent a Student
    struct Student {
        string name;
        mapping(uint => bool) completedCourses;
        uint totalCredits;
        bool exists;
    }

    // Mapping from institution address to list of courses
    mapping(address => mapping(uint => Course)) public institutionCourses;

    // Mapping from student address to student details
    mapping(address => Student) public students;

    // Event to be emitted when a student completes a course
    event CourseCompleted(address indexed student, uint courseId, uint credits);

    // Event to be emitted when credits are transferred
    event CreditsTransferred(address indexed fromStudent, address indexed toStudent, uint credits);

    // Function to add a new course by the institution
    function addCourse(uint courseId, string memory courseName, uint credits) public {
        require(!institutionCourses[msg.sender][courseId].exists, "Course already exists");
        institutionCourses[msg.sender][courseId] = Course(courseName, credits, true);
    }

    // Function to register a student
    function registerStudent(address studentAddress, string memory studentName) public {
        require(!students[studentAddress].exists, "Student already registered");
        
        // Access the storage reference for the student
        Student storage student = students[studentAddress];
        
        // Assign values individually
        student.name = studentName;
        student.totalCredits = 0;
        student.exists = true;
    }

    // Function to mark a course as completed by a student
    function completeCourse(address studentAddress, uint courseId) public {
        require(students[studentAddress].exists, "Student not registered");
        require(institutionCourses[msg.sender][courseId].exists, "Course does not exist");
        require(!students[studentAddress].completedCourses[courseId], "Course already completed");

        students[studentAddress].completedCourses[courseId] = true;
        students[studentAddress].totalCredits += institutionCourses[msg.sender][courseId].credits;

        emit CourseCompleted(studentAddress, courseId, institutionCourses[msg.sender][courseId].credits);
    }

    // Function to transfer credits from one student to another
    function transferCredits(address fromStudent, address toStudent, uint courseId) public {
        require(students[fromStudent].exists, "Sender student not registered");
        require(students[toStudent].exists, "Recipient student not registered");
        require(students[fromStudent].completedCourses[courseId], "Sender has not completed the course");

        uint creditsToTransfer = institutionCourses[msg.sender][courseId].credits;
        students[fromStudent].totalCredits -= creditsToTransfer;
        students[toStudent].totalCredits += creditsToTransfer;

        emit CreditsTransferred(fromStudent, toStudent, creditsToTransfer);
    }

    // Function to get the total credits of a student
    function getTotalCredits(address studentAddress) public view returns (uint) {
        require(students[studentAddress].exists, "Student not registered");
        return students[studentAddress].totalCredits;
    }
}
