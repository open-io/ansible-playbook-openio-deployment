#! /usr/bin/env bats

@test 'zookeeper - status' {
  if ! (echo "172.17.0.3 172.17.0.4 172.17.0.33" | grep -q -w ${SUT_IP}); then
    skip
  fi
  run bash -c "echo mntr |curl telnet://${SUT_IP}:6005"
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'leader' ]] || [[ "${output}" =~ 'follower' ]]
}
