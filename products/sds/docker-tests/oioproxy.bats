#!/usr/bin/env bats

@test 'OIO PROXY - status' {
  run bash -c "curl http://${SUT_IP}:6006/v3.0/status"
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'counter req.time.admin_drop_cache_POST' ]]
}
