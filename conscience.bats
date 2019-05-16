#! /usr/bin/env bats

# Tests
run_only_test() {
  if ! (echo "172.17.0.33" | grep -q -w ${SUT_IP}); then
    skip
  fi
}

get_ID_node() {
  #for i in $(docker ps -aq); do
  #  export SUT_ID=$(docker inspect $i| grep -B400 ${SUT_IP}|grep Hostname\" | uniq| sed -e 's@.*"\(.*\)",@\1@')
  #done
  if [[ "$SUT_IP" == "172.17.0.2" ]]; then export SUT_ID=${TRINODE_ID1}; fi 
  if [[ "$SUT_IP" == "172.17.0.3" ]]; then export SUT_ID=${TRINODE_ID2}; fi 
  if [[ "$SUT_IP" == "172.17.0.33" ]]; then export SUT_ID=${TRINODE_ID3}; fi 
}

setup() {
  run_only_test
  get_ID_node
}

@test 'Conscience - up' {
  run docker exec -ti ${SUT_ID} bash -c "/usr/bin/oio-tool ping ${SUT_IP}:6000"
  echo "output: "$output
  echo "status: "$status
  [[ "${status}" -eq "0" ]]
  [[ "${output}" =~ 'PING OK' ]]
}
