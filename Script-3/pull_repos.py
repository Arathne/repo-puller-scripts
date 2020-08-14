#!/usr/bin/python3

#**********
#
# @author   Edgar Torrez
# @date    February 4, 2020
# 
# @purpose
#    clone repositories of students from github
#
# @info
#    use 'python pull_repos.py -h' for parameters
#
# @required
#    --repo   repository name to search for
#    
# @default
#    + will search for a file called 'token' with the github token in the first line in the current directory
#
#    + will create a new folder to put all the cloned repositories in and will be placed in current directory
#
#    + name of folder will be the same as repository
#
#    + deletes any previous data if repository folder already exists
#
# @readme
#    I removed the ability to authenticate with a username and password after being locked out from my iu account 
#    for a day because it thought I was a bot since I was sending too many requests. Signing in once with username
#    and password is equivalent to signing in once through canvas. Now imagine doing that 100 times...
# 
#**********


try:
	from git import Repo
	import getpass
	import os
	import shutil
	import argparse
except:
	print("Unable to import modules for pull_repos")
	exit(-1)


#**********
# @purpose    clone repository of a student
#
# @parameter-1   username
# @parameter-2   password
# @parameter-3   domain                                   ex: github.com or github.iu.edu
# @parameter-4   username of student
# @parameter-5   repository to be cloned
# @parameter-6   location to place contents
# @parameter-7   new name of the folder with contents
# 
# @returns   true if repository was pulled successfully
#
def cloneRepo( username, password, domain, student, repo, path, dirName ):
	
	success = True
	repo = student + '/' + repo + '.git'
	dir = os.path.join( path, dirName )
	createDirectory( dir )
	
	url = "https://%s:%s@%s/%s" % ( username, password, domain, repo )

	try:
		Repo.clone_from( url, dir, branch='master' )
		print( "*** SUCCESS ***    " + student )
	except:
		removeDirectory( dir )
		success = False
		print( "*** FAILED  ***    " + student )
	
	return success


#**********
# @purpose   create a string from the array that will go to missing.txt 
#
# @parameter-1   array with student information
#
# @returns   string
#
def missingFormat( array ):
	output = ''
	for i in range( len(array) ):
		output = output + "{0:15}".format( array[i] )
	return output


#**********
# @purpose   create a string from the array that will be the folder name
#
# @parameter-1   array with student information
#
# @notes   the reason this is different is because I don't want the userid to be in the folder
#
# @returns   string
#
def folderFormat( array ):
	output = ''
	for i in range( len(array) ):
		if i > 0:
			output = output + array[i]
			if i < len(array) - 1:
				output = output + '-'
	return output


#**********
# @purpose   create a folder if it does not exist
#
# @parameter-1   path to where the new folder will be created
#
# @returns   none
#
def createDirectory( path ):
	if not os.path.exists( path ):
		os.mkdir( path )


#**********
# @purpose   removes a folder
#
# @parameter-1   path to the folder to be deleted
#
# @notes   folders are deleted recursively 
#
# @returns   none
#
def removeDirectory( path ):
	shutil.rmtree( path, ignore_errors=True  )




#**********
# @purpose   allows for the ability to have different arguments when running the program
#
# @parameters   none
#
# @returns   argument parser
#
def createParse():
	parser = argparse.ArgumentParser()
	parser.add_argument( '-d', '--domain',
	                     required=False,
                         metavar='DOMAIN',
                         help='ex: github.com || github.iu.edu')

	parser.add_argument( '-r', '--repo',
                         required=True,
                         metavar='STRING',
                         help='name of the repository to be cloned')
	

	parser.add_argument( '-s', '--roster',
                         required=False,
                         metavar='FILE',
                         help='roster file to use for retrieving student userid')

	parser.add_argument( '-t', '--token',
	                     required=False,
                         metavar='FILE',
                         help='token to be used for authentication')
	
	parser.add_argument( '-n', '--name',
	                     required=False,
                         metavar='STRING',
                         help='name of output folder')
	
	
	parser.add_argument( '-p', '--path',
	                     required=False,
                         metavar='PATH',
                         help='where the newly created folder will go')

	return parser.parse_args()




#**********
# @notes   data from before the first comma should be the students username
#   
# @steps
#   open file that contains student data
#   go through each student
#   find students repository and clone it
#   if couldn't find students repository
#      place them in a missing.txt file
#
if __name__ == "__main__":
	args = createParse()
	REPO = args.repo
	
	if args.domain == None:
		DOMAIN = 'github.iu.edu'
	else:
		DOMAIN = args.domain
	
	if args.roster == None:
		ROSTER = 'roster.txt'
	else:
		ROSTER = args.roster
	
	if args.token == None:
		TOKEN = 'token'
	else:
		TOKEN = args.token
	
	if args.name == None:
		NAME = REPO
	else:
		NAME = args.name
	
	if args.path == None:
		PATH = '.'
	else:
		PATH = args.path

	PATH = os.path.join( PATH, NAME )

	removeDirectory( PATH )
	createDirectory( PATH )
	missing = open( os.path.join(PATH, 'missing.log'), 'a' )

	with open( TOKEN ) as file:
		USERNAME = file.readline().strip()
		PASSWORD = 'x-oauth-basic'
	
	with open( ROSTER, 'r' ) as rosterFile:
		for line in rosterFile:
			line = line.rstrip('\n')
			student = line.split(',')
			userid = student[0]
			
			successClone = cloneRepo( USERNAME, PASSWORD, DOMAIN, userid, REPO, PATH, folderFormat(student) )
			
			if successClone == False:
				missing.write( missingFormat(student) + "\n" )
	
	missing.close()
