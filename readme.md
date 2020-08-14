# Repo Pulling

#### previous scripts that have been previously used to pull repositories.

> three scripts to rule them all




## Script-1

#### written in python by Dr. Hill and managed by Gabriel Shelton with shell scripts. I don't remember what I did to get this script running, but I had to edit some of the code to get to work properly.




## Script-2

#### the problem with the previous script is that it felt too over complicated and was difficult to manage. The solution to this was to create a minimal amount of scripts. it's also the only one that can manage moss.


| script | description |
| ------ | ------ |
| pullRepo.sh           | pulls repositories from students |
| list.sh               | displays missing/successful in the terminal |
| archive-moss.sh       | zips html files and all sub-links associated |
| moss.pl               | sends files to moss.stanford.edu and returns a link |
| cheater-buster9000.sh | sends files to moss.pl and the run archive-moss.sh |


##### PRE-REQUISITES:

* make sure you can connect to github.iu.edu through ssh
* generate roster.txt using Script-3 or create it in the following format: 'firstname,lastname,username'


##### EXAMPLES:

```sh
$ ./pullRepo.sh roster.txt csci24000_spring2020_A1

$ ./list.sh csci24000_spring2020_A1

$ ./cheaterBuster9000.sh csci24000_spring2020_A1 cpp cc

$ ./cheaterBuster9000.sh csci24000_spring2020_A1 cpp cc past_submissions

```

> output folder in generated folder has logs and zip file

> moss is like a woman that only listens when she feels like it. Sometimes it works, most of the time it doesn't




# Script-3

#### two issues Script-3 tries to solve is giving the user complete freedom of flags to pass into the script and ability to run script in linux/windows. To solve this, it's created in python instead of bash which also resulted in at least 2x performance increase. The reason for this is that Script-2 uses 'git clone (students)' while Script-3 uses the api. Better in every way except for dealing with moss.



| script | description |
| ------ | ------ |
| generate_roster.py | converts csv to roster.txt |
| pull_repos.py      | pulls repositories from students |
| zipper.py          | zips directory |


##### PRE-REQUISITES:

* update token
* generate/create roster.txt



##### EXAMPLES:

```sh
$ python generate_roster.py -c student_roster.csv -f userid last first

$ python pull_repos.py -r csci24000_spring2020_A1

$ python zipper.py -s csci24000_spring2020_A1

```
