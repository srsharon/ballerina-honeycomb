// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/io;
import ballerina/log;

http:Client studentService = new("http://localhost:9292",
config = { httpVersion: "2.0" });

public function main() {
    http:Request req = new;
    int operation = 0;
        while (operation != 6) {
            // Print options menu to choose from.
            io:println("Select operation.");
            io:println("1. Add student");
            io:println("2. View all students");
            io:println("3. Delete a student");
            io:println("4. Make a mock error");
            io:println("5: Get a student's marks");
            io:println("6. Exit \n");

            // Read user's choice.
            string choice = io:readln("Enter choice 1 - 5: ");
            if (!isInteger(choice)) {
                io:println("Choice must be of a number");
                io:println();
                continue;
            }

            var intOp = int.convert(choice);

            if (intOp is int){
                operation = intOp;
            }

            // Program runs until the user inputs 6 to terminate the process.
            if (operation == 6) {
                break;
            }
            if (operation == 1) {
                // User chooses to add a student.
                addStudent(req);
            } else if (operation == 2) {
                // User chooses to list down all the students.
                viewAllStudents();
            } else if (operation == 3) {
                // User chooses to delete a student by Id.
                 deleteStudent();
            } else if (operation == 4) {
                // User chooses to make a mock error.
                 makeError();
            } else if (operation == 5){
                // User chooses to get the marks of a particular student.
                getMarks();
            } else {
                io:println("Invalid choice \n");
            }
        }
    }



function isInteger(string input) returns boolean {
    string regEx = "\\d+";
    boolean|error isInt =  input.matches(regEx);
    if(isInt is boolean) {
        return isInt;
    }
    return false;
}

// Function  to add students to database.
function addStudent(http:Request req) {
    // Get student name, age mobile number, address.
    var name = io:readln("Enter Student name: ");
    var age = io:readln("Enter Student age: ");
    var mobile = io:readln("Enter mobile number: ");
    var add = io:readln("Enter Student address: ");

    var intAge =  int.convert(age);
    var intMob = int.convert(mobile);

    if(intAge is int && intMob is int) {
        // Create the request as JSON message.
        json jsonMsg = { "name": name, "age":intAge, "mobNo":intMob, "address": add ,"id": 0};
        req.setJsonPayload(jsonMsg);

    }else {
        io:println("Adding students failed");
        return;
    }

    // Send the request to students service and get the response from it.
    var resp = studentService->post("/records/addStudent", req);

    if (resp is http:Response){
        var jsonMsg = resp.getJsonPayload();
        if(jsonMsg is json){
                string message = "Status: " + jsonMsg["Status"] .toString() + " Added Student Id :- " +
                    jsonMsg["id"].toString();
                // Extracting data from JSON received and displaying.
                io:println(message);
        }else {
            log:printError("Error in JSON", err = jsonMsg);
            }

    }
    else {
        log:printError("Error in response", err = resp);
    }
}

function viewAllStudents() {
    // Sending a request to list down all students and get the response from it.
    var response = studentService->post("/records/viewAll", null);

    if (response is http:Response ){
        var jsonMsg = response.getJsonPayload();

        if(jsonMsg is json){
            string message = "";

            if(jsonMsg.length() >=1){
                int i = 0;
                while (i < jsonMsg.length()) {
                message = "Student Name: " + jsonMsg[i]["name"] .toString() + ", " + " Student Age: " + jsonMsg[i]["age"] .toString();
                io:println(message);
                i += 1;
                }
            }else {
                // Notify user if no records are available.
                message = "\n Student record is empty";
                io:println(message);
            }

        } else {
            log:printError("Error ", err = jsonMsg);
          }

    }else {
        log:printError("Error ", err = response);
        }
}

function deleteStudent() {
    // Get student id.
    string id = io:readln("Enter student id: ");

    // Request made to find the student with the given id and get the response from it.
    var resp = studentService->get("/records/deleteStu/" + id );

    if (resp is http:Response){
        var jsonMsg = resp.getJsonPayload();
            if(jsonMsg is json){
            string message = jsonMsg["Status"].toString();
            io:println("\n"+ message + "\n");
            }
            else {
                log:printError("Error ", err = jsonMsg);
            }
    }

}

function makeError() {
    var response = studentService->get("/records/testError");

    if (response is http:Response){
        var msg = response.getTextPayload();

        if (msg is string){
            io:println("\n"+ msg + "\n");
        } else {
            log:printError("Error", err = msg);
        }
    }
    else {
        log:printError("Error", err = response);
    }
}

function getMarks() {
    // Get student id.
    var id = io:readln("Enter student id: ");
    // Request made to get the marks of the student with given id and get the response from it.
    var response = studentService->get("/records/getMarks/" + id);

    if (response is http:Response){
        var jsonMsg = response.getJsonPayload();

        if(jsonMsg is json){
            string message = "";
            if (jsonMsg.length() >= 1) {
            // Validate to check if student with given ID exist in the system.
            message = "Maths: " + jsonMsg[0]["maths"] .toString() + " English: " + jsonMsg[0]["english"] .toString() + " Science: " + jsonMsg[0]["science"] .toString();
            }else {
                message = "Data not available. Check if student's mark is added or student might not be in our system.";
            }
            io:println("\n"+ message + "\n");
        }
        else {
            log:printError("Error ", err = jsonMsg);
        }
    }
     else {
            log:printError("Error ", err = response);
    }
}
