#!/usr/bin/python3

#**********
#
# @author   Edgar Torrez
# @date   January 17, 2020
#
# @purpose
#    reads .csv file that was exported from canvas and creates a txt file from it in any format requested
# 
# @info
#    use 'python generate_roster.py -h' for info on file parameters
# 
# @run
#    python generate_roster.py --format first last userid
#    python generate_roster.py --format last last userid --output students.txt
#    python generate_roster.py --format userid last first --csv student_roster.csv
# 
# @default
#    searches for student_roster.csv
#    outputs into roster.txt
#
#**********


try:
    import pandas
    import argparse
    from pandas import ExcelWriter
    from pandas import ExcelFile
except:
    print("Unable to import modules for generate_roster")
    exit(-1)


#**********
# @purpose   read from .csv file and place first name, last name, and username into a data frame
#
# @parameter-1   path to .csv file
# 
# @notes   .csv file must be the one generated on canvas
#
# @returns   dataframe
#
def retrieve_data( path ):
    studentData = pandas.DataFrame( columns=['first', 'last', 'userid'] )
    sheet = pandas.read_csv( path ) ## read csv file
    for i in sheet.index: ## go through each row
        userid = sheet[ 'SIS Login ID' ][i] ## find name and username
        student = sheet[ 'Student' ][i].split(', ')
        if len(student) > 1: ## must be an actual name
            firstName = student[1] ## store data
            lastName = student[0]
            studentData =  studentData.append( {'first':firstName, 'last':lastName, 'userid':userid }, ignore_index=True )
    return studentData


#**********
# @purpose   appends data to a file and creates a new file if necessary
#
# @parameter-1   string
#
# @notes   make sure to open and close the file when needed
#
# @returns   none
#
def append_to_file( line ):
    rosterFile.write( line.lower() + '\n' )


#**********
# @purpose   uses a dataframe to create a string based on parameters provided
# 
# @parameter-1   row of the element             int
# @parameter-2   dataframe to be searched       dataframe
# @parameter-3   columns retrieved              array
#
# @notes   allows for the ability to make any string format of students
#          argument need to be columns in the dataframe
#
# @returns   string
#
def student_to_string( index, dataframe, argument ):
    output = ""
    for i in range( len(argument) ): # iterate through each argument
        output = output + dataframe[ argument[i] ][index]  # grabs the data from column based on argument
        if i != len(argument)-1:
            output = output + seperator
    return output


#**********
# @purpose   allows for the ability to have different arguments when running the program
#
# @parameter-1   none
#
# @returns   argument parser
#
def create_parse():
    parser = argparse.ArgumentParser()
    parser.add_argument( '-c', '--csv',
                         required=False,
                         metavar='FILE',
                         help='exported csv roster file from canvas')
    
    parser.add_argument('-f', '--format',
                        required=True,
                        nargs='+',
                        help='creates format of text file',
                        choices=['first','last','userid'] )
    
    parser.add_argument('-o', '--output',
                       required=False,
                       metavar='PATH',
                       help='directory for output file')
    
    parser.add_argument('-s', '--sep',
                        required=False,
                        help='seperate each entity by specified character',
                        metavar='CHAR')

    return parser.parse_args()
    


#**********
# @steps
#   place student info into a dataframe
#   format students appropriately
#   output formatted students into a text file   
#
if __name__ == "__main__":
    args = create_parse()
    
    if args.csv == None: # initialize csv path
        path = 'student_roster.csv'
    else:
        path = args.csv

    if args.output == None: # initialize output path
        target = 'roster.txt'
    else:
        target = args.output

    if args.sep == None: # initialize seperator
        seperator = ','
    else:
        seperator = args.sep

    if len( args.format ) > 0: # must have at least 1 parameter
        studentData = retrieve_data( path )
        rosterFile = open( target, 'w' )
            
        for i, row in studentData.iterrows(): # go through each row of students
            line = student_to_string(i, studentData, args.format) # format students accordingly
            line = line.replace(' ', '-') # remove any spaces
            append_to_file( line )
    else:
        print( "\nAt least 1 parameter is required" )
        print( "ex: python " + sys.argv[0] + " last userid first\n" )
