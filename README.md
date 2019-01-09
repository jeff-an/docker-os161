Build-Test Script and Docker Image for CS350
===
- Docker image: minimalistic linux image with sys161 and os161 build tools, 24% smaller than other os161 images
- Makefile: simple commands to run os161 directly, recompile the kernel, and recompile user programs
- Testing: bash script with options to run together with GDB, run assignment tests, and loop through multiple test runs
- **Please ⭐ or fork if you found this repo helpful**

Prerequisites
---
- You must have Docker installed and running on your system

Install
---
- Clone the repository and navigate inside the docker-os161 directory
- Obtain a copy of the os161 source code to work off of - the directory should be in the path PATH_TO_REPO/docker-os161/os161-1.99
  - If you would like a fresh copy, you can run these commands:
  ```
    wget https://www.student.cs.uwaterloo.ca/~cs350/os161_repository/os161.tar.gz -O os161.tar.gz
    tar -xzf os161.tar.gz
    rm os161.tar.gz
  ```
- Your local environment is now ready to build the Docker image!

Running OS161 for the first time
---
- Make sure you have the os161-1.99 folder in your repository directory and then run `make all`
- If you don't want to run OS161 directly and just want to be placed within the linux environment along with the OS161 source code, run `make linux`. After running this, you can follow Waterloo CS350 instructions to build the kernel, build user programs, and run OS161 manually if you like (this is essentially what the make commands do, however)

Updating OS161
---
- After you change kernel source code, run `make newkernel` to rebuild the kernel and run OS161 again
- After you change user source code, run `make newuser` to rebuild user programs and run OS161 again
- If you would like to do both of the above at the same time, run `make all` again

Testing
---
- First, run `make linux` to be placed within the dockerized linux environment
- Now you can access the testing script, which is `bin/build-test.sh`
- See the options below for running tests using this script. For example, to just run GDB alongside OS161 without rebuilding, you can run `./bin/build-test.sh -m`

build-test.sh Options
---
- default: builds from source, runs side by side with GDB in Tmux
- `-b   ` - only build from source, don't run after
- `-c   ` - continuous build loop
- `-d   ` - output debug text when tests are run
- `-m   ` - run with gdb tmux panels without rebuild
- `-r   ` - run only (no gdb tmux or rebuild)
- `-t {}` - run test {test alias}
- `-l {}` - loop all following tests {#} times and log result in `logs/` directory
- `-w   ` - clear all logs

Included Tests | Test Aliases
---
- **Usage** `./build-test.sh -t {test name | test alias} -t {...`
- **Usage (with loops)** `./build-test.sh -l {# of loops} -t {test name | test alias} -t {...`
- **A1**
  - `l   |  lock       `   - test locks with sy2
  - `cv  |  convar     `  - test conditional variables with sy3
  - `t   |  traffic    `   - A1 test for traffic simulation with 4 15 0 1 0 params
- **A2A**
  - `2aa |  onefork    ` - uw-testbin/onefork
  - `2ab |  pidcheck   ` - uw-testbin/pidcheck
  - `2ac |  widefork   ` - uw-testbin/widefork
  - `2ad |  forktest   ` - testbin/forktest
- **A2B**
  - `2ba |  hogparty   ` - uw-testbin/hogparty
  - `2bb |  sty        ` - testbin/sty
  - `2bc |  argtest    ` - uw-testbin/argtest
  - `2bd |  argtesttest` - uw-testbin/argtesttest
  - `2be |  add        ` - testbin/add
- **A3**
  - `3a  |  vm-data1   `  - uw-testbin/vm-data1
  - `3b  |  vm-data3   `  - uw-testbin/vm-data3
  - `3c  |  romemwrite `  - uw-testbin/romemwrite
  - `3d  |  vm-crash2  `  - uw-testbin/vm-crash2
  - `3e  |  vm-data1   `  - uw-testbin/vm-data1
  - `3el |  lvm-data1  ` - loop 5 x uw-testbin/vm-data1
  - `3f  |  sort       `  - testbin/sort
  - `3fl |  lsort      ` - loop 5 x testbin/sort
  - `3g  |  lmatmult   `  - testbin/matmult
  - `3gl |  lmatmult   ` - loop 5 x testbin/matmult
  - `3h  |  lwidefork  `  - loop 5 x uw-testbin/widefork
  - `3i  |  lhogparty  `  - loop 5 x uw-testbin/hogparty

