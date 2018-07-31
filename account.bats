#! /usr/bin/env bats

@test 'Account - status' {
  run bash -c "curl http://${SUT_IP}:6009/status"
  #accounts=$(docker exec -ti $TRINODE_ID1 bash -c "openio account list --oio-ns OPENIO -f value")
  echo "output: "$output
  echo "status: "$status
  echo "account: "$accounts
  [[ "${status}" -eq "0" ]]
  #[[ "${output}" =~ '{"account_count": 0}' ]]
}
