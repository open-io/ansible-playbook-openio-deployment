#! /usr/bin/env bats

@test 'rdir - up' {
  run nc -zv ${SUT_IP} 6301
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'succeeded' ]] || [[ "${output}" =~ 'Connected to' ]]
}
