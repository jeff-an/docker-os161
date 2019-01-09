#!/usr/bin/env bash

# runs OS/161 in SYS/161 and attaches GDB, side by side in a tmux window

# set up bash to handle errors more aggressively - a "strict mode" of sorts
set -e # give an error if any command finishes with a non-zero exit code
set -u # give an error if we reference unset variables
set -o pipefail # for a pipeline, if any of the commands fail with a non-zero exit code, fail the entire pipeline with that exit code

cs350dir="/root/cs350-os161"
sys161dir="/root/sys161"
ASSIGNMENT=ASST0
TEST=false
LOOP=false
OPTIONS=false
DEBUG=false

# copy in the SYS/161 default configuration
mkdir --parents $cs350dir/root
cp --update $sys161dir/share/examples/sys161/sys161.conf.sample $cs350dir/root/sys161.conf
# overwrite with our own configuration if it is there
cp $cs350dir/os161-1.99/sys161.conf $cs350dir/root/sys161.conf || :

# build kernel
cd $cs350dir/os161-1.99
./configure --ostree=$cs350dir/root --toolprefix=cs350-
cd $cs350dir/os161-1.99/kern/conf
./config $ASSIGNMENT
cd $cs350dir/os161-1.99/kern/compile/$ASSIGNMENT
bmake depend
bmake
bmake install

