#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
    . "$DIR/.bash_colors"

clr_green "Discovering docker hosts.."
#clean old container hosts
ansible_hosts_file=production
start_anchor="## docker containers start"
end_anchor="## docker containers end"
sed -i "/$start_anchor/,/$end_anchor/d" $ansible_hosts_file 

echo $start_anchor >> $ansible_hosts_file
echo "[docker_containers]" >> $ansible_hosts_file
while read id name
do
    str=$(docker port $id 22)
    host=$(echo $str | cut -d ":" -f1)
    port=$(echo $str | cut -d ":" -f2)
    clr_cyan "found:  $name"
    echo $name " ansible_port="$port" ansible_host="$host >> $ansible_hosts_file
done < <(docker ps --format "{{.ID}} {{.Names}}" 2>/dev/null)
echo $end_anchor >> $ansible_hosts_file
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i production docker_containers.yml
