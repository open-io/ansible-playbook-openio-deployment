#!/bin/bash
YELLOW="\e[33m"
NC="\e[39m"

N=${1:-3}
usage(){
    echo "Usage: $0 [N containers]" 
    echo "	N: Number of container"
    echo ""
    echo -e "$YELLOW Your user needs to be in th \"docker\" group $NC"
    exit 1
}

docker ps > /dev/null 2>&1
if [[ $? == 1 ]]; then
  usage
fi

echo -e "${YELLOW}Replace with the following in the file named \"01_inventory.ini\" $NC"
echo '[all]'
for i in $(seq 1 $N); do
  ID=$(docker run \
    --detach --privileged \
    --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
    centos/systemd /usr/lib/systemd/systemd)
  echo "node${i} ansible_host=$(docker inspect --format='{{.Config.Hostname}}' $ID) ansible_user=root ansible_connection=docker"
done

echo -e "
${YELLOW}Change the variables in group_vars/openio.yml and adapt to your host capacity $NC"
