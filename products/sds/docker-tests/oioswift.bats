#!/usr/bin/env bats

setup() {
  TOKEN=$(curl -v -H 'X-Storage-User: demo:demo' -H 'X-Storage-Pass: DEMO_PASS' http://${SUT_IP}:6007/auth/v1.0  2>&1 | grep X-Auth-Token: | awk '{sub(/\r/, ""); print $3}')
  STORAGE_URL=$(curl -v -H 'X-Storage-User: demo:demo' -H 'X-Storage-Pass: DEMO_PASS' http://${SUT_IP}:6007/auth/v1.0  2>&1 | grep X-Storage-Url | awk '{sub(/\r/, ""); print $3}')
}

@test 'OIO SWIFT - status account' {
  run curl -i ${STORAGE_URL} -X GET -H "X-Auth-Token: ${TOKEN}"

  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'HTTP/1.1 204 No Content' ]]
  [[ "${output}" =~ 'X-Account-Object-Count: 0' ]]
  [[ "${output}" =~ 'X-Account-Container-Count: 0' ]]
}
