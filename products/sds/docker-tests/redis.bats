#!/usr/bin/env bats

# Doesn't work on ubuntu target ...
#@test 'Redis - stats' {
#  run bash -c "echo 'INFO' | nc -w 1 ${SUT_IP} 6011 | grep uptime_in_seconds"
#  echo "output: "$output
#  echo "status: "$status
#  [[ "${status}" -eq "0" ]]
#}
#
#@test 'Sentinel - Quorum' {
#  if ! (echo "172.17.0.3 172.17.0.4 172.17.0.33" | grep -q -w ${SUT_IP}); then
#    skip
#  fi
#  run bash -c "echo 'SENTINEL ckquorum OPENIO-master-1' | nc ${SUT_IP} 6012 | grep 'OK 3 usable Sentinel'"
#  echo "output: "$output
#  echo "status: "$status
#  [[ "${status}" -eq "0" ]]
#}

@test 'Redis - up' {
  run nc -zv ${SUT_IP} 6011
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'succeeded' ]] || [[ "${output}" =~ 'Connected to' ]]
}

@test 'Sentinel - up' {
  run nc -zv ${SUT_IP} 6012
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'succeeded' ]] || [[ "${output}" =~ 'Connected to' ]]
}

