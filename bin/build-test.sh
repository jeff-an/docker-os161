# By Andrew Paradi, Jeff An | Source at https://github.com/adrw/docker-cs350-os161
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

function status {
  Reset='   tput sgr0'       # Text Reset
  Red='     tput setaf 1'          # Red
  Green='   tput setaf 2'        # Green
  Blue='    tput setaf 4'         # Blue
  div="********************************************************************************"
  scriptname="$(basename "$0")"
  case "$1" in
    a)        echo "" && echo "$($Blue)<|${scriptname:0:1}$($Reset) [ ${2} ] ${div:$((${#2}+9))}" ;;
    b)        echo "$($Green)ok: [ ${2} ] ${div:$((${#2}+9))}$($Reset)" ;;
    s|status) echo "$($Blue)<|${scriptname:0:1}$($Reset) [ ${2} ] ${div:$((${#2}+9))}" ;;
    t|title)  echo "$($Blue)<|${scriptname}$($Reset) [ ${2} ] ${div:$((${#2}+8+${#scriptname}))}" ;;
    e|err)    echo "$($Red)fatal: [ ${2} ] ${div:$((${#2}+12))}$($Reset)" ;;
  esac
}

function show_help {
  status a "Help :: Build and Run Options"
  echo "{ }       { default: builds from source, runs with gdb in Tmux }"
  echo "-b        { only build, don't run after }"
  echo "-c        { continuous build loop }"
  echo "-d        { set debug mode }"
  echo "-m        { only run, with gdb tmux panels }"
  echo "-r        { only run, don't build, don't run with gdb }"
  echo "-t {}     { run test {test alias}  }"
  echo "-l {}     { loop all following tests {#} times and log result }"
  echo "-w        { clear all logs }"
  echo ""
}

function show_test_help {
  status "Help :: Test Aliases"
  echo "./build-test.sh -l {# of loops} -t {test name | code} -t {..."
  status a "A1"
  echo "lock        l   { test locks with sy2 }"
  echo "convar      cv  { test conditional variables with sy3 }"
  echo "traffic     t   { A1 test for traffic simulation with 4 15 0 1 0 params }"
  status a "A2a"
  echo "onefork     2aa { uw-testbin/onefork }"
  echo "pidcheck    2ab { uw-testbin/pidcheck }"
  echo "widefork    2ac { uw-testbin/widefork }"
  echo "forktest    2ad { testbin/forktest }"
  status a "A2b"
  echo "hogparty    2ba { uw-testbin/hogparty }"
  echo "sty         2bb { testbin/sty }"
  echo "argtest     2bc { uw-testbin/argtest }"
  echo "argtesttest 2bd { uw-testbin/argtesttest }"
  echo "add         2be { testbin/add }"
  echo ""
  status a "A3"
  echo "vm-data1    3a  { uw-testbin/vm-data1 }"
  echo "vm-data3    3b  { uw-testbin/vm-data3 }"
  echo "romemwrite  3c  { uw-testbin/romemwrite }"
  echo "vm-crash2   3d  { uw-testbin/vm-crash2 }"
  echo "vm-data1    3e  { uw-testbin/vm-data1 }"
  echo "lvm-data1   3el { loop 5 x uw-testbin/vm-data1 }"
  echo "sort        3f  { testbin/sort }"
  echo "lsort       3fl { loop 5 x testbin/sort }"
  echo "lmatmult    3g  { testbin/matmult }"
  echo "lmatmult    3gl { loop 5 x testbin/matmult }"
  echo "lwidefork   3h  { loop 5 x uw-testbin/widefork  }"
  echo "lhogparty   3i  { loop 5 x uw-testbin/hogparty }"
  echo ""
}

# display an error if we're not running inside a Docker container
if ! grep docker /proc/1/cgroup -qa; then
  cs350dir="$HOME/cs350-os161"
  sys161dir="/u/cs350/sys161"
  if [[ ! $HOME == /u* ]]; then
    status err 'ERROR :: PLEASE RUN THIS SCRIPT ON UW ENVIRONMENT OR DOCKER CONTAINER'
    exit 1
  fi
fi

function run_build {
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

  # build user-level programs
  cd $cs350dir/os161-1.99
  bmake
  bmake install
}

function run_continuous_build {
  for (( ; ; )); do
    run_build
  done
}

function run_tmux {
  # set up the simulator run
  cd $cs350dir/root
  if ! which tmux &> /dev/null; then
    apt-get install --yes -qq tmux
  fi

  # set up a tmux session with SYS/161 in one pane, and GDB in another
  tmux kill-session -t os161 || true # kill old tmux session, if present
  tmux new-session -d -s os161 # start a new tmux session, but don't attach to it just yet
  tmux split-window -v -t os161:0 # split the tmux window in half
  tmux send-keys -t os161:0.0 'sys161 -w kernel' C-m # start SYS/161 and wait for GDB to connect
  tmux send-keys -t os161:0.1 'cs350-gdb kernel' C-m # start GDB
  sleep 0.5 # wait a little bit for SYS/161 and GDB to start
  tmux send-keys -t os161:0.1 "dir $cs350dir/os161-1.99/kern/compile/$ASSIGNMENT" C-m # in GDB, switch to the kernel dir
  tmux send-keys -t os161:0.1 'target remote unix:.sockets/gdb' C-m # in GDB, connect to SYS/161
  tmux send-keys -t os161:0.1 'c' # in GDB, fill in the continue command automatically so the user can just press Enter to continue
  tmux attach-session -t os161 # attach to the tmux session
}

function run_only {
  cd $cs350dir/root
  sys161 kernel-$ASSIGNMENT "${*}"
}

function run_loop {
  mkdir -p $cs350dir/log
  logfile=$cs350dir/log/$log_filename
  echo $logfile
  echo -n "1"
  denom=$((LOOP / 75 + 1))
  chunk_char="."
  chunk_size=$((75 / LOOP - 1))
  chunk=$chunk_char
  for i in $(seq 1 $chunk_size); do chunk+=$chunk_char; done
  for i in $(seq 1 $LOOP)
  do
    [ $denom -eq 0 ] && echo -n $chunk
    [ $denom -ne 0 ] && [ $((i%denom)) -eq 0 ] && echo -n $chunk
    status l "${i} of ${LOOP}" >> $logfile
    sys161 kernel-$ASSIGNMENT "${pre_command} ${test_command}" &>> $logfile
    echo "" >> $logfile
  done
  echo $i
  success=$(grep -o "${success_word}" ${logfile} | wc -w)
  # success=$(grep -o "${success_word}" ${logfile} | wc -w)
}

function run_test {
  log_ext=".log"
  log_filename="`date '+%Y%m%d-%H%M%S'`-"

  start_test="Test ::"
  test_command=""
  pre_command=""

  cd $cs350dir/root

  case $TEST in
    h|\?)         show_test_help
                  exit 0
                  ;;
    l|lock)       status a "${start_test} Lock "
                  test_command="sy2;q"
                  log_filename+="lock${log_ext}"
                  success_word="done"
                  ;;
    cv|convar)    status a "${start_test} Conditional Variable "
                  test_command="sy3;q"
                  log_filename+="cond-var${log_ext}"
                  success_word="done"
                  ;;
    t|traffic)    status a "${start_test} A1 Traffic 4 15 0 1 0 "
                  test_command="sp3 4 15 0 1 0;q"
                  log_filename+="traffic${log_ext}"
                  success_word="Simulation"
                  ;;
    2aa|onefork)  status a "${start_test} uw-testbin/onefork "
                  test_command="${pre_command} p uw-testbin/onefork;q"
                  log_filename+="a2a-onefork${log_ext}"
                  success_word="took"
                  pre_command="dl 8192; "
                  ;;
    2ab|pidcheck) status a "${start_test} uw-testbin/pidcheck "
                  test_command="${pre_command} p uw-testbin/pidcheck;q"
                  log_filename+="a2a-pidcheck${log_ext}"
                  success_word="took"
                  pre_command="dl 8192; "
                  ;;
    2ac|widefork) status a "${start_test} uw-testbin/widefork "
                  test_command="${pre_command} p uw-testbin/widefork;q"
                  log_filename+="a2a-widefork${log_ext}"
                  success_word="took"
                  pre_command="dl 8192; "
                  ;;
    2ad|forktest) status a "${start_test} testbin/forktest "
                  test_command="${pre_command} p testbin/forktest;q"
                  log_filename+="a2a-forktest${log_ext}"
                  success_word="took"
                  pre_command="dl 8192; "
                  ;;
    2ba|hogparty) status a "${start_test} uw-testbin/hogparty "
                  test_command="${pre_command} p uw-testbin/hogparty;q"
                  log_filename+="a2b-hogparty${log_ext}"
                  success_word="zzz"
                  pre_command="dl 16384; "
                  ;;
    2bb|sty)      status a "${start_test} testbin/sty "
                  test_command="${pre_command} p testbin/sty;q"
                  log_filename+="a2b-sty${log_ext}"
                  success_word="succeeded"
                  pre_command="dl 16384; "
                  ;;
    2bc|argtest)  status a "${start_test} p uw-testbin/argtest first second third "
                  test_command="${pre_command} p uw-testbin/argtest first second third;q"
                  log_filename+="a2b-argtest${log_ext}"
                  success_word="\[NULL\]"
                  pre_command="dl 16384; "
                  ;;
    2bd|argtesttest)
                  status a "${start_test} uw-testbin/argtesttest "
                  test_command="${pre_command} p uw-testbin/argtesttest;q"
                  log_filename+="a2b-argtesttest${log_ext}"
                  success_word="\[NULL\]"
                  pre_command="dl 16384; "
                  ;;
    2be|add)      status a "${start_test} testbin/add 2 4"
                  test_command="${pre_command} p testbin/add 2 4;q"
                  log_filename+="a2b-add${log_ext}"
                  success_word="Answer:"
                  pre_command="dl 16384; "
                  ;;
    3a|vm-data1)  status a "${start_test} uw-testbin/vm-data1"
                  test_command="${pre_command} p uw-testbin/vm-data1;q"
                  log_filename+="a3a-vm-data1${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  # pre_command="dl 32800; "
                  ;;
    3b|vm-data3)  status a "${start_test} uw-testbin/vm-data3"
                  test_command="${pre_command} p uw-testbin/vm-data3;q"
                  log_filename+="a3b-vm-data3${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3c|romemwrite)
                  status a "${start_test} uw-testbin/romemwrite"
                  test_command="${pre_command} p uw-testbin/romemwrite;q"
                  log_filename+="a3c-romemwrite${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3d|vm-crash2) status a "${start_test} uw-testbin/vm-crash2"
                  test_command="${pre_command} p uw-testbin/vm-crash2;q"
                  log_filename+="a3d-vm-crash2${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3e|vm-data1)  status a "${start_test} uw-testbin/vm-data1"
                  test_command="${pre_command} p uw-testbin/vm-data1;q"
                  log_filename+="a3e-vm-data1${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3el|lvm-data1)
                  status a "${start_test} loop 5 x uw-testbin/vm-data1"
                  test_command="${pre_command} p uw-testbin/vm-data1; p uw-testbin/vm-data1; p uw-testbin/vm-data1; p uw-testbin/vm-data1; p uw-testbin/vm-data1;q"
                  log_filename+="a3el-lvm-data1${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3f|sort)      status a "${start_test} testbin/sort"
                  test_command="${pre_command} p testbin/sort;q"
                  log_filename+="a3f-sort${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3fl|lsort)    status a "${start_test} loop 5 x testbin/sort"
                  test_command="${pre_command} p testbin/sort; p testbin/sort; p testbin/sort; p testbin/sort; p testbin/sort;q"
                  log_filename+="a3fl-lsort${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3g|matmult)   status a "${start_test} testbin/matmult"
                  test_command="${pre_command} p testbin/matmult;q"
                  log_filename+="a3g-matmult${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3gl|lmatmult) status a "${start_test} loop 5 x testbin/matmult"
                  test_command="${pre_command} p testbin/matmult; p testbin/matmult; p testbin/matmult; p testbin/matmult; p testbin/matmult; q"
                  log_filename+="a3gl-lmatmult${log_ext}"
                  success_word="took"
                  pre_command="dl 32768; "
                  ;;
    3h|lwidefork) status a "${start_test} uw-testbin/widefork "
                  test_command="${pre_command} p uw-testbin/widefork; p uw-testbin/widefork; p uw-testbin/widefork; p uw-testbin/widefork; p uw-testbin/widefork; q"
                  log_filename+="a3h-widefork${log_ext}"
                  success_word="took"
                  pre_command="dl 8192; "
                  ;;
    3i|lhogparty)
                  status a "${start_test} loop 5 x uw-testbin/hogparty"
                  test_command="${pre_command} p uw-testbin/hogparty; p uw-testbin/hogparty; p uw-testbin/hogparty; p uw-testbin/hogparty; p uw-testbin/hogparty; q"
                  log_filename+="a3i-hogparty${log_ext}"
                  success_word="zzz"
                  pre_command="dl 16384; "
                  ;;
    *)            show_test_help
                  read -p "Run test ${TEST}? [y/n/enter]" -n 1 -r
                  echo    # (optional) move to a new line
                  if [[ $REPLY =~ ^[Nn]$ ]]
                  then
                    exit 0
                  fi
                  status a "${start_test} ${TEST} "
                  test_command="${TEST};q"
                  log_filename+="${TEST}${log_ext}"
                  success_word="took"
                  ;;
  esac

  if [[ "$DEBUG" == false ]]; then
    pre_command=""
  fi

  if [[ "$LOOP" != false ]]; then
    run_loop
  else
    run_only "${pre_command} ${test_command}"
    i=1
    success=1
  fi

  if [[ "$success" == "$i" ]]; then
    status b "Test :: Fin ${success} / $i"
  else
    status err "Test :: Fin ${success} / $i"
  fi
}

status t "Welcome to os161 built-test.sh"
status s "Andrew Paradi. https://github.com/adrw/docker-cs350-os161"
status b "os161 :: ${ASSIGNMENT}"

while getopts "h?:bcdmrwl:t:" opt; do
  OPTIONS=true
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    b)  echo "Option Registered: build"
        run_build
        ;;
    c)  echo "Option Registered: continuous build"
        run_continuous_build
        ;;
    d)  echo "Option Registered: run with debug output"
        DEBUG=true
        ;;
    m)  echo "Option Registered: run with gdb tmux"
        run_tmux
        ;;
    r)  echo "Option Registered: run"
        run_only ""
        ;;
    l)  LOOP=$OPTARG
        echo "Option Registered: loop following test ${LOOP} times"
        ;;
    t)  TEST=$OPTARG
        echo "Option Registered: test ${TEST}"
        run_test
        TEST=false
        ;;
    w)  touch $cs350dir/log/tmp.log; rm $cs350dir/log/*.log
        echo "Option Registered: wipe logs"
        status b "Logs Cleared"
        exit 0
        ;;
    esac
done

if [[ "$OPTIONS" == false ]]; then
  run_build
  run_tmux
fi

exit 0
