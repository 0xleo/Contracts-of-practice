// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <=0.9.0;

// here I explain the construction of the contract step by step...

contract crowdFunding{

    enum State { open, closed } //project status, open or closed, if it is closed the users will not be able to fund the project, ...
    //... (an enum was used so that only one of the two indices can be used when calling the change status function "changeState").

    struct Project { //the struct structure pattern to be used by the projects to be created is declared
    address payable owner; //payable so that the address that created the project is the one that receives the funds sent by users
    string projectName;
    string description;
    uint256 targetFunds; //here is stored the amount of wei target in fundraising
    uint256 currentFunds; //here is stored the amount of funds currently collected
    string id; //project identifier to be used as the key of the value in mapping
    State state; //the state is declared with the State type (the enum previously mentioned)
    }

    struct Contribution { //the struct to be entered as the value in the mapping, with the data type array
    address contributor; //the contributor's address will be stored here
    uint value; //the amount of value the contributor contributed will be stored here
    } 
    
    Project[] public projects; //the "Project" data type that was previously declared as a struct is now used to...
    //... declare "projects" as an array data type, (therefore "projects" is now an array with the internal elements of the struct "Project")

    mapping( string => Contribution[] ) public contributions; //a mapping is declared that will have as key the ids of the projects created, ...
    //... and as value it will have both the address of the contributor and also the amount in wei contributed by that contributor
    // example:
    // mapping( string id => address contributor && uint value ) public contributions;


    //string variables are stored in calldata to optimize the use of space, since the value of these variables will not be modified
    function createProject(string calldata project_Name, string calldata _description, uint256 target_Funds, string calldata _id) public { 
         require( target_Funds > 0, "You are transferring 0 funds" ); //condition for contributors to contribute an amount greater than zero
         Project memory project = Project(payable(msg.sender), project_Name, _description, target_Funds, 0 , _id, State.open); 
         //the properties of the struct "Project" are transferred to the variable "project" declared with the data type "Project", then the values...
         //... are assigned to the properties of project, these values assigned to project are the same that were obtained previously by the parameter of the function
         projects.push(project); //with the push function "project" is added to the array "projects" which also has internally the properties...
         //... of the struct Project since that array was declared with the data type Project
    }    

    function fund(uint projectIndex) public payable notOwner(projectIndex) { 
        //(function to fund the project), the "projectIndex" parameter is used so that the user can select the index of the project to which he wants to contribute, ...
        //... the "payable" is so that the property of the global variable "msg" can be used, which is ( msg.value ), the modifier "notOwner" is used so that only the ...
        //... user can fund the project and not its own creator
        Project memory project = projects[projectIndex]; //the index number is passed to the array "projects" to tell the array which... 
        //... element or project is being referenced, then it is matched to the project variable of type Project
        require( msg.value + project.currentFunds < project.targetFunds, "its amount exceeds the limit of the project's funding objective, try a smaller amount..." );
        //condition that allows the function to be activated only when the amount contributed by the contributor...
        //... plus current funds is less than the project fundraising goal
        //in this case the value of the element can be accessed in the following two ways, (1) "project.currentFunds" and (2) "projects[projectIndex].currentFunds"
        require( projects[projectIndex].currentFunds < projects[projectIndex].targetFunds, "the project has already reached its target funding limit..." );
        // "projects[projectIndex].currentFunds" and "projects[projectIndex].targetFunds"... 
        //... this is the form (2) I mentioned in the previous step in order to access the value of the element
        require( msg.value != 0, "You are transferring 0 funds..." ); //so that the user does not have to pay a commission unnecessarily for his error in the amount
        require( project.state == State.open, "the project is closed" ); //so that you can only contribute to the project if the project is open
         project.owner.transfer(msg.value); //the "transfer" function to be able to transfer the value in wei of the transaction made by the user to the project owner
         project.currentFunds += msg.value; //here the amount contributed by the user is added to all previous contributions to the project, i.e. to "currentFunds" with the sign +=
         projects[projectIndex] = project; //is the way to save the changes in the struct "Project" of the array, ...
         //... to update the project that is saved in the array 
         contributions[project.id].push(Contribution(msg.sender, msg.value));
         //to the mapping "contributions" is added as an element with the function "push" the value in wei that the user contributed and the address from...
         //... which he made the contribution, (these two elements are inside the struct "Contribution")
         emit senderAndFund(msg.sender, msg.value, project.currentFunds); //the "senderAndFund" event is triggered in order to see the depositor's address, ...
         //... the value in wei deposited, and the total funds deposited in the project
    } 

    modifier notOwner(uint projectIndex) { //the modifier function is declared, the parameter is passed the index of the project entered by the user
        require( projects[projectIndex].owner != msg.sender, "You cannot fund your project..." );_;
        //condition so that only the user and not the owner can execute the function in which this modifier "notOwner" is present, ...
        //... the index number "projectIndex" entered by the user is used to specifically access the project element inside the array of structs "Project[] public projects"                   
    }    

    modifier isOwner(uint projectIndex) { //the modifier function is declared, the parameter is passed the index of the project entered by the user
        require( projects[projectIndex].owner == msg.sender,
         "only owner, sorry..." );_;
        //condition so that only the owner can execute the function in which this modifier "isOwner" is present, ...
        //... the index number "projectIndex" entered by the user is used to specifically access the project element inside the array of structs "Project[] public projects"
    }   
    
    event senderAndFund( //the event is declared in order to see the values of the following variables in the function where it is emitted
         address depositSender, //depositor's address
         uint valueSender, //value in wei deposited by the user
         uint CurrentTotalFund //total funds deposited
    );

    function changeState(uint projectIndex, State change_State ) public isOwner(projectIndex) {
    //the function to change the project status is declared, the project index to be changed is passed as parameter, ...
    //... then the status to be changed of type State( open=0 closed=1 ), the modifire function "isOwner(projectIndex)" is used
        Project memory project = projects[projectIndex]; //the index number is passed to the array "projects" to tell the array which... 
        //... element or project is being referenced, then it is matched to the project variable of type Project
        require( project.state != change_State, "You are changing the (state) to the previous one" );
        // condition so that it can only be changed (state) if the state entered is different from the previous one
        projects[projectIndex] = project; //is the way to save the changes in the struct "Project" of the array, ...
         //... to update the project that is saved in the array 
    }

    function changeName(uint projectIndex, string memory change_Name) public isOwner(projectIndex){
    //the function to change the name of the project is declared, the index of the project to be renamed is passed as a parameter, ...
    //... then pass the name to be changed, the modifire function "isOwner(projectIndex)" was used 
         Project memory project = projects[projectIndex]; //the index number is passed to the array "projects" to tell the array which... 
        //... element or project is being referenced, then it is matched to the project variable of type Project
         project.projectName = change_Name; //the change is saved
         projects[projectIndex] = project; //is the way to save the changes in the struct "Project" of the array, ...
         //... to update the project that is saved in the array 
     }

    function changeDescription(uint projectIndex, string memory change_Description) public isOwner(projectIndex){ 
    //the same pattern logic of the previous function
         Project memory project = projects[projectIndex]; 
         project.projectName = change_Description;
         projects[projectIndex] = project; 
     }     

    function changeTargetFunds(uint projectIndex, uint256 change_TargetFunds) public isOwner(projectIndex){ 
    //the same pattern logic of the previous function
         Project memory project = projects[projectIndex]; 
         require(project.targetFunds != change_TargetFunds, "You are changing the (TargetFunds) to the previous one" );
         project.targetFunds = change_TargetFunds;
         projects[projectIndex] = project; 
     }         

    function changeEverything(uint projectIndex, string memory change_Name, string memory change_description, uint256 change_targetFunds, State change_State) public isOwner(projectIndex){
    //the same pattern logic of the previous function but with all elements together   
         Project memory project = projects[projectIndex];
         project.projectName = change_Name;
         project.description = change_description;
         project.targetFunds = change_targetFunds;
         project.state = change_State;
         projects[projectIndex] = project;
         
     }
