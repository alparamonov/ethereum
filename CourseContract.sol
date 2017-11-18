pragma solidity ^0.4.15;

contract CourseContract {
    string public name;
    Course public course;
    uint256 public total;
    uint8 private decimals;

    struct Course { // Struct
        string name;
        uint8 maxAttendees;
        uint8 currentlyAttending;
        address[] attendees;
        address trainer;
        uint256 feeInWei;
    }

    /* This maps address to boolean to check if account is frozen */
    mapping (address => bool) private frozenAccount;

    /* Initializes contract with course name, fee in wei, and maximum allowed attendees */
    function CourseContract(string courseName, uint256 feeInWei, uint8 maxAttendees, uint8  _decimals) public {
        decimals = _decimals;
        name = courseName;
        course = Course(courseName, maxAttendees, 0, new address[](0), msg.sender, feeInWei);
    }

    function enroll() payable public {
        // 10000000000000000 wei / 0.01 ether
        require(msg.value == course.feeInWei);

        if (course.attendees.length < course.maxAttendees) {
            require(!frozenAccount[msg.sender]);     
            require(!frozenAccount[course.trainer]);        
            course.attendees.push(msg.sender);
            course.currentlyAttending += 1;
            total += msg.value;
        }

        if (course.attendees.length == course.maxAttendees) {
            start();
        }
    }

    event Transfer(address indexed _attendee, address indexed trainer, uint256 fee);

    function start() public {
        require(msg.sender == course.trainer);

        Transfer(msg.sender, course.trainer, course.feeInWei); 

        Start(course.attendees);
        kill();
    }

    event Start(address[] attendees);

    function kill() private {
          selfdestruct(course.trainer); //Destruct the contract
    }
}
