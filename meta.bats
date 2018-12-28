#! /usr/bin/env bats

@test 'Meta0 - up' {
  run nc -zv ${SUT_IP} 6001
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'succeeded' ]] || [[ "${output}" =~ 'Connected to' ]]
}

@test 'Meta1 - up' {
  run nc -zv ${SUT_IP} 6110
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'succeeded' ]] || [[ "${output}" =~ 'Connected to' ]]
}

@test 'Meta2 - up' {
  run nc -zv ${SUT_IP} 6120
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'succeeded' ]] || [[ "${output}" =~ 'Connected to' ]]
}
