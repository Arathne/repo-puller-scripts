#!/usr/bin/python3

##
# @file     generate_roster.py
# @brief    Take a csv file exported from the grades section of canvas and convert it to a roster usable by the script
#
# @date     2019-01-09
# @author   gachshel    Gabriel Shelton

ROSTER_NAME = './roster.txt'

# Imports
try:
    from sys import argv
    import os
    from os import path

except:
    print("Unable to import modules for main.py")
    exit(-1)

## 
# @brief    Entry Function
# @details
# parameter 1: grade csv exported from Canvas
# parameter 2: roster directory name
def main():
    # Read the file storing each line in file_contents
    file_contents = []
    with open(argv[1], 'r') as file:
        file_contents = file.readlines()

    studentList = getStudentList(file_contents)

    # Make sure the roster directory is added as specified by arg_2
    rosterDirectory = argv[2]
    if not path.exists(rosterDirectory):
        os.makedirs(rosterDirectory)

    with open(rosterDirectory + '/' + ROSTER_NAME, 'w') as file:
        for student in studentList:
            file.write(student)

##
# @brief    Get list of students firstname_lastname\tusername for the roster file, from file_contents
# @param    [list]      The file's contents seperated by comma's
# @return   [list]      List of student's name and username to be written to a file for the class roster
def getStudentList(file_contents):
    # Store all of the students
    studentList = []

    # Iterate over the file and store each student as firstname_lastname\tusername into the list
    for line in file_contents[2:]:
        student = line.split(',')
        lastname = student[0].lower()[1:]
        firstname = student[1].lower()[1:-1]
        username = student[3]
        studentList.append(firstname + '_' + lastname + '\t' + username + '\n')

    return studentList

if(__name__ == "__main__"):
    main()
