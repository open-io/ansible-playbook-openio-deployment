#!/usr/bin/env bats

# Tests
run_only_test() {
  if ! (echo "172.17.0.2 172.17.0.3 172.17.0.33" | grep -q -w ${SUT_IP}); then
    skip
  fi
}

setup() {
  run_only_test
}

@test 'ECD - request' {
  run curl -i -X HEAD ${SUT_IP}:6017
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'HTTP/1.1 403 FORBIDDEN' ]]
}

