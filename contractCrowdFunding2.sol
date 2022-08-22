// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <=0.9.0;

contract crowdUpdate{

    enum State { open, closed } 

    struct Project { 
    address payable owner; 
    string projectName;
    string description;
    uint256 targetFunds; 
    uint256 currentFunds; 
    string id; 
    State state; 
    }

    struct Contribution { 
    address contributor; 
    uint value; 
    }
    
//    Project[] public projects;

    mapping( string => Project ) public allProjects; 

    mapping( string => address ) public indexOwner;

    mapping( string => Contribution ) public contributions; 

    function createProject(string calldata project_Name, string calldata _description, uint256 target_Funds, string memory _id) public {          
         //Project memory project;
         //_id = Project.id;
         require( target_Funds > 0, "Your target cannot be 0" );                
         allProjects[_id] = (Project(payable(msg.sender), project_Name, _description, target_Funds, 0 , _id, State.open)); 
         indexOwner[_id] = msg.sender;
    }    

    function fund(string memory projectIndex) public payable notOwner(projectIndex) { 
        Project memory project = allProjects[projectIndex]; 
        require( msg.value + project.currentFunds < project.targetFunds, "Its amount exceeds the limit of the project's funding objective, try a smaller amount..." );        
        require( allProjects[projectIndex].currentFunds < allProjects[projectIndex].targetFunds, "the project has already reached its target funding limit..." );
        require( msg.value != 0, "You are transferring 0 funds..." ); 
        require( project.state == State.open, "The project is closed" ); 
         project.owner.transfer(msg.value); 
         project.currentFunds += msg.value; 
         allProjects[projectIndex] = project; 
         contributions[project.id] = (Contribution(msg.sender, msg.value));
         emit senderAndFund(msg.sender, msg.value, project.currentFunds);
    } 

    modifier notOwner(string memory projectIndex) {
        require( indexOwner[projectIndex] != msg.sender, "You cannot fund your project..." );_;                        
    }    

    modifier isOwner(string memory projectIndex) {
        require( indexOwner[projectIndex] == msg.sender,
         "Only owner, sorry..." );_;
    }   
    
    event senderAndFund( 
         address depositSender, 
         uint valueSender, 
         uint CurrentTotalFund 
    );

    function changeState(string memory projectIndex, State change_State ) public isOwner(projectIndex) {
        Project memory project = allProjects[projectIndex]; 
        require( project.state != change_State, "You are changing the (state) to the previous one" );
        allProjects[projectIndex] = project;
    }

    function changeName(string memory projectIndex, string memory change_Name) public isOwner(projectIndex){
         Project memory project = allProjects[projectIndex]; 
         project.projectName = change_Name;
         allProjects[projectIndex] = project;
     }

    function changeDescription(string memory projectIndex, string memory change_Description) public isOwner(projectIndex){ 
         Project memory project = allProjects[projectIndex]; 
         project.projectName = change_Description;
         allProjects[projectIndex] = project; 
     }     

    function changeTargetFunds(string memory projectIndex, uint256 change_TargetFunds) public isOwner(projectIndex){ 
         Project memory project = allProjects[projectIndex]; 
         require(project.targetFunds != change_TargetFunds, "You are changing the (TargetFunds) to the previous one" );
         project.targetFunds = change_TargetFunds;
         allProjects[projectIndex] = project; 
     }         

    function changeEverything(string memory projectIndex, string memory change_Name, string memory change_description, uint256 change_targetFunds, State change_State) public isOwner(projectIndex){
         Project memory project = allProjects[projectIndex];
         project.projectName = change_Name;
         project.description = change_description;
         project.targetFunds = change_targetFunds;
         project.state = change_State;
         allProjects[projectIndex] = project;
         
     }


}
