#! /usr/bin/env bats

# Tests
run_only_test() {
  if ! (echo "172.17.0.2 172.17.0.33" | grep -q -w ${SUT_IP}); then
    skip
  fi
}

setup() {
  run_only_test
}

@test 'Conscience - up' {
  run nc -zv ${SUT_IP} 6000
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'succeeded' ]]
}
