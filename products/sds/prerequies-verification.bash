#!/bin/bash
if [ "$_" != "$0" -a "$_" != "/bin/bash" ]; then
  cat 1>&2 <<EOF
"*** ERROR ***
  This script must be run with bash !

EOF
  exit 1
fi

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[39m"


# where to save results (array)
declare -a results

# Function to be called at exit to print tests results
function my_exit {
  local overall=0
  local output=""

  echo
  for result in "${results[@]}"; do
    local ret=${result%%:*}
    local cmd=${result##*:}
    if [ -z "$ret" ]; then
      cmd="${BLUE}*** $cmd ***${NC}"
    else
      if [ $ret -eq 0 ]; then
        ret="${GREEN}OK${NC}"
      else 
        ret="${RED}KO${NC}"
        overall=1
      fi
    fi
    output+="$cmd,$ret\n"
  done


  output+="${BLUE}-------------------${NC}\n"

  output+="Overall check result,"
  if [ $overall -eq 0 ]; then
    output+="${GREEN}OK${NC}\n"
  else
    output+="${RED}KO${NC}\n"
  fi

  echo -e $output | column -t -s,
}

# Catch 'Exit' signal
trap 'my_exit' EXIT

# Function to run command
# Usage:
# run <command> [<label>] [stop]
# <command> is a shell command to be run
# <label> is the label of the command (defaults to <command>)
# <stop> whether to stop the script on failure (defaults to continue)
function run {

  local cmd="$1"

  local label="${2:--}"
  if [ "$label" = "-" ]; then
    label="$cmd"
  fi

  local stop="$3"
  if [ "$stop" = "true" -o "$stop" = "1" ]; then
    stop=1
  else
    stop=0
  fi

  echo -e "${YELLOW}${label}.${NC}"

  eval $cmd
  local ret=$?
  results+=("$ret:$label")

  echo -ne "${YELLOW}Result: ${NC}"
  if [ $ret -eq 0 ]; then
    echo -e "${GREEN}OK${NC}"
  else 
    echo -e "${RED}KO${NC}"
  fi
  echo "--"

  if ((stop)); then
    exit $ret
  else
    return $ret
  fi
}

function group {
  local label="$*"
  echo
  echo "--------"
  echo "## ${label}."
  results+=(":$label")
}

_OS=unknown
function check_os {
  # CentOS
  if [ -f /etc/centos-release ]; then
    cat /etc/centos-release | grep '^CentOS Linux release 7\.'
    local ret=$?
    [[ $ret -eq 0 ]] && _OS=CENTOS
    return $ret
  fi

  if [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release | grep '^DISTRIB_RELEASE=\(16\.04\|18\.04\)$'
    local ret=$?
    [[ $ret -eq 0 ]] && _OS=UBUNTU
    return $ret
  fi

  # OS not supported
  return 1
}

KERNEL_MIN_VERSION=3.10
function check_kernel {

  local kernel="$(uname -r)"
  echo $kernel
  kernel=${kernel%%-*}

  [ "$(printf '%s\n' $kernel $KERNEL_MIN_VERSION | sort -V | head -n 1)" = "$KERNEL_MIN_VERSION" ]
  #return $?
}


group "Basic checks"
run "check_os" "OS"
run 'id; [[ $(id -u) -eq 0 ]]' "Run as root"
run "python --version 2>&1 | grep '^Python \(3\|2\.7\)\.'" "Python exists"
if [ $_OS = "CENTOS" ]; then
  run '[ -x /usr/sbin/getenforce -a "$(/usr/sbin/getenforce)" = "Disabled" ]' "SELinux is disabled"
  run 'systemctl is-active firewalld; [[ $? -ne 0 ]]' 'firewalld is active'
  run 'systemctl is-enabled firewalld; [[ $? -ne 0 ]]' 'firewalld is disabled'
  run 'systemctl is-active sshd' 'OpenSSH Server is active'
  run 'systemctl is-enabled sshd' 'OpenSSH Server is enabled'
fi

if [ $_OS = "UBUNTU" ]; then
  run 'systemctl is-active apparmor; [[ $? -ne 0 ]]' 'apparmor is not running'
  run 'systemctl is-enabled apparmor; [[ $? -ne 0 ]]' 'apparmor is disabled'
  run 'systemctl is-active ufw; [[ $? -ne 0 ]]' 'ufw is not running'
  run 'systemctl is-enabled ufw; [[ $? -ne 0 ]]' 'ufw is disabled'
  run 'systemctl is-active ssh' 'OpenSSH Server is active'
  run 'systemctl is-enabled ssh' 'OpenSSH Server is enabled'
fi


run 'check_kernel' "Kernel >= $KERNEL_MIN_VERSION"
