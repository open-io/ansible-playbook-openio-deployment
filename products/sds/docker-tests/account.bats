#!/usr/bin/env bats

@test 'Account - status' {
  run bash -c "curl http://${SUT_IP}:6009/status"
  echo "output: "$output
  echo "status: "$status
  echo "account: "$accounts
  [[ "${status}" -eq "0" ]]
}
