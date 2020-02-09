#!/usr/bin/env bats

@test 'rawx - status' {
  run curl -s ${SUT_IP}:6200/stat
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'counter req.hits' ]]
  [[ "${output}" =~ 'counter req.hits.raw 0' ]]
}
