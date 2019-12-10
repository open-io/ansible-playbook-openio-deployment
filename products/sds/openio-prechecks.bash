#!/bin/bash
#
# This script must be run on each node on which OpenIO SDS will be installed.
# It must be run using bash:
#   /path/to/openio-prechecks.bash
#   bash openio-prechecks.bash
#
# It will check the basics before continuing with ansible inventory and stuff
#
# Copyright (C) 2019 OpenIO
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


#
# Ensure script is run from bash and not from another shell
#
if [ "$_" != "$0" -a "$_" != "/bin/bash" ]; then
  cat 1>&2 <<EOF

"*** ERROR ***
  This script must be run with bash !
EOF
  exit 1
fi


#
# Colors
#
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
NC="\e[39m"

#
# where to save results (array)
#
declare -a results

#
# Function to be called at exit to print tests results
#
function my_exit {
  local overall=0
  local output=""

  echo
  for result in "${results[@]}"; do

    # Each value is formatted as follow: %{label}:%{return value}
    local label=${result##*:} # Extract test label
    local ret=${result%%:*} # Extract return value

    if [ -z "$ret" ]; then # if not return value
      label="${BLUE}*** $label ***${NC}" # just a group label
    else
      if [ $ret -eq 0 ]; then
        ret="${GREEN}OK${NC}" # OK
      elif [ $ret -eq 2 ]; then
        ret="${MAGENTA}WARN${NC}" # WARN
      else
        ret="${RED}KO${NC}"   # KO
        overall=1             # set overall return value
      fi
    fi
    output+="$label,$ret\n"
  done


  output+="${BLUE}-------------------${NC}\n"

  output+="Overall check result,"
  if [ $overall -eq 0 ]; then
    output+="${GREEN}OK${NC}\n"
  else
    output+="${RED}KO${NC}\n"
  fi

  # final output before exiting the script
  echo -e $output | column -t -s,
}

#
# Catch 'Exit' signal
#
trap 'my_exit' EXIT

#
# Function to run command
# Usage:
# run <command> [<label>] [stop]
# <command> is a shell command to be run
# <label> is the label of the command (defaults to <command>)
# <stop> whether to stop the script on failure (defaults to continue)
#
# The command to run must return the following values:
# - 0 on success
# - 1 on error
# - 2 on warning (it will be considered as a success anyway)
#
function run {

  local cmd="$1"

  local label="${2:--}" # defaults to '-'
  if [ "$label" = "-" ]; then # if '-'
    label="$cmd" # defaults to cmd
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
  results+=("$ret:$label") # Save result to global array

  # print result
  echo -ne "${YELLOW}Result: ${NC}"
  if [ $ret -eq 0 ]; then
    echo -e "${GREEN}OK${NC}"
  elif [ $ret -eq 2 ]; then
    echo -e "${MAGENTA}WARN${NC}"
  else
    echo -e "${RED}KO${NC}"
  fi
  echo "--"

  # return or exit depending on stop argument
  if ((stop)); then
    exit $ret
  else
    return $ret
  fi
}

#
# Add a group
#
function group {
  local label="$*"
  echo
  echo "--------"
  echo "## ${label}."
  results+=(":$label")
}

#
# check_os
#
# Only CentOS 7, Ubuntu 16.04 and Ubuntu 18.04
#
_OS=unknown
function check_os {
  # CentOS
  if [ -f /etc/centos-release ]; then
    cat /etc/centos-release | grep '^CentOS Linux release 7\.'
    local ret=$?
    [[ $ret -eq 0 ]] && _OS=CENTOS
    return $ret
  fi

  # Ubuntu
  if [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release | grep '^DISTRIB_RELEASE=\(16\.04\|18\.04\)$'
    local ret=$?
    [[ $ret -eq 0 ]] && _OS=UBUNTU
    return $ret
  fi

  # OS not supported
  return 1
}

#
# check_cpu_governor
#
#
function check_cpu_governor {
  if compgen -G /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1; then
    grep -v -e performance /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null|cut -d"/" -f6|paste -sd" "
    [[ ${PIPESTATUS[0]} -eq 0 ]] && return 1
  else
    echo "cpufreq not installed."
    return 1
  fi
  return 0
}

#
# check_mtu
#
#
function check_jumbo {
  interfaces=$(ip link list | awk '/^[0-9]+:.* mtu/{if($5 < 9000) { print $2 }}')
  if [ -n "$interfaces" ]; then
    echo -n "Interfaces with MTU < 9000: "
    echo $interfaces | sed 's/://g'
    return 2
  fi
  return 0
}

#
# check_intel_pstate
#
#
function check_intel_pstate {
  if [ -r /sys/devices/system/cpu/intel_pstate/status ]; then
    grep -q off /sys/devices/system/cpu/intel_pstate/status || return 2
  fi
  return 0
}

#
# chek_kernel >= 3.10
#
KERNEL_MIN_VERSION=3.10
function check_kernel {

  local kernel="$(uname -r)"
  echo $kernel
  kernel=${kernel%%-*}

  [ "$(printf '%s\n' $kernel $KERNEL_MIN_VERSION | sort -V | head -n 1)" = "$KERNEL_MIN_VERSION" ]
  #return $?
}

#
# Main checks
#

group "Basic checks"
run "check_os" "OS"
run 'id; [[ $(id -u) -eq 0 ]]' "Run as root"
run "python --version 2>&1 | grep '^Python \(3\|2\.7\)\.'" "Python exists"
run 'getent passwd 120; [[ $? -ne 0 ]]' "uid 120 is available"
run 'getent group 220; [[ $? -ne 0 ]]' "gid 220 is available"
run "[[ $(df | grep '% /$' | awk '{print $2}') -gt 10**6 ]]" "Enough space on root partition"
if [ $_OS = "CENTOS" ]; then
  run '[ -x /usr/sbin/getenforce -a "$(/usr/sbin/getenforce)" = "Disabled" ]' "SELinux is disabled"
  run 'systemctl is-active firewalld; [[ $? -ne 0 ]]' 'firewalld is active'
  run 'systemctl is-enabled firewalld; [[ $? -ne 0 ]]' 'firewalld is disabled'
  run 'systemctl is-active sshd; [[ $? -eq 0 ]]' 'OpenSSH Server is active'
  run 'systemctl is-enabled sshd; [[ $? -eq 0 ]]' 'OpenSSH Server is enabled'
  run 'curl -qsI http://mirror.openio.io/pub/repo/openio/sds/current/centos/ | head -n1 | grep "200 OK"' 'OpenIO repository is reachable'
fi

if [ $_OS = "UBUNTU" ]; then
  run 'systemctl is-active apparmor; [[ $? -ne 0 ]]' 'apparmor is not running'
  run 'systemctl is-enabled apparmor; [[ $? -ne 0 ]]' 'apparmor is disabled'
  run 'systemctl is-active ufw; [[ $? -ne 0 ]]' 'ufw is not running'
  run 'systemctl is-enabled ufw; [[ $? -ne 0 ]]' 'ufw is disabled'
  run 'systemctl is-active ssh; [[ $? -eq 0 ]]' 'OpenSSH Server is active'
  run 'systemctl is-enabled ssh; [[ $? -eq 0 ]]' 'OpenSSH Server is enabled'
  run 'curl -qsI http://mirror.openio.io/pub/repo/openio/sds/current/Ubuntu/ | head -n1 | grep "200 OK"' 'OpenIO repository is reachable'
fi

run 'check_kernel' "Kernel >= $KERNEL_MIN_VERSION"

group "Hardware checks"
run 'check_intel_pstate' 'Intel P-state is better off'
run 'check_cpu_governor' 'CPU scaling governor set to performance'
run 'check_jumbo' 'Network devices Jumbo Frames MTU'
