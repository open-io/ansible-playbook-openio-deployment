#! /usr/bin/env bats

@test 'zookeeper - status' {
  run bash -c "echo mntr |curl telnet://${SUT_IP}:6005"
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'leader' ]] || [[ "${output}" =~ 'follower' ]]
}
