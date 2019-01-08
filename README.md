Build-Test Script and Docker Image for CS350
===
- Docker image: Minimalistic docker image with sys161 and os161 build tools, 24% smaller than other os161 images
- build-test.sh: os161 compile routines with options for looped tests and Tmux split screen GDB debugging
- Built while taking the CS350 Operating Systems course at University of Waterloo
- Not under active development as of Aug 9, 2017
- **Please ⭐ or fork if you found this repo helpful**

Install
---
- Login to a University of Waterloo server/terminal or install Docker on own machine
- In Terminal, navigate to parent directory of where your os161 directory will be, then run:
  ```bash
  $ curl -s https://raw.githubusercontent.com/adrw/docker-os161/master/bootstrap.sh | bash -s
  ```
- This will create folder structure, do clean install of os161, and download the `Makefile` and `build-test.sh`
- There may be places such as in `submit.sh` that you will need to edit the file and add your username...etc

Getting Started
---
- If on your own computer within your os161 directory, start the Docker container with `make`
  - To build image from scratch, run `make build` or `make rebuild` (build without cached Docker images)
- Compile and run os161 with `./build-test.sh` and any of the options below

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

Just the Docker Image
---
- Already have Docker installed and want just an os161 image?
- Download image with `docker pull andrewparadi/cs350-os161:latest`
- Run with `docker run -it -v {absolute local os161 src directory}:/root/cs350-os161 --entrypoint /bin/bash andrewparadi/cs350-os161:latest`

Resources
---
- [**Docker Hub andrewparadi/cs350-os161 Image**](https://hub.docker.com/r/andrewparadi/cs350-os161/)
- [**Uberi/uw-cs350-development-environment**](https://github.com/Uberi/uw-cs350-development-environment)
- [**University of Waterloo CS350 Operating Systems Course Site**](https://www.student.cs.uwaterloo.ca/~cs350/)
- [**Source Code on GitHub**](https://github.com/andrewparadi/docker-os161)
