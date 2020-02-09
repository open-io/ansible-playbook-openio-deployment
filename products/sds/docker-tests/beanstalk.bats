#!/usr/bin/env bats

@test 'Beanstalkd - stats' {
  run bash -c "echo -e \"stats\r\nquit\r\n\" |curl telnet://${SUT_IP}:6014"
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'uptime' ]]
  [[ "${output}" =~ 'version' ]]
}
