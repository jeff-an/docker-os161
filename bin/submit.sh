# By Andrew Paradi | Source at https://github.com/adrw/docker-cs350-os161
#!/usr/bin/env bash

# use by ./submit {assignment #, ie. 0}

ssh {username}@ubuntu1404.student.cs.uwaterloo.ca "cd $HOME/cs350-os161; rm *.tgz; /u/cs350/bin/cs350_submit $1"
