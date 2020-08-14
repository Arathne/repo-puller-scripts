#!/usr/bin/python3

try:
	import os
	import shutil
	import argparse
except:
	print("Unable to import modules for zipper")
	exit(-1)


def createParse():
	parser = argparse.ArgumentParser()
	parser.add_argument( '-d', '--destination',
	                     required=False,
                         metavar='PATH',
                         help='destination of zip file')
	
	parser.add_argument( '-s', '--source',
	                     required=True,
                         metavar='PATH',
                         help='directory to zip')
	
	parser.add_argument( '-n', '--name',
	                     required=False,
                         metavar='STRING',
                         help='name of new zip file')

	return parser.parse_args()



if __name__ == "__main__":
	args = createParse()

	if args.destination == None:
		destination = '.'
	else:
		destination = args.destination

	if args.name == None:
		name = os.path.basename(args.source)
	else:
		name = args.name

	destination = os.path.join( destination, name )
	source = os.path.abspath( args.source )
	parent_dir = os.path.dirname( source )

	shutil.make_archive( destination, 'zip', parent_dir, os.path.basename(source) )

