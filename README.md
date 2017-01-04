# pundun-ansible
Ansible roles for Pundun management

Usage:

```sh
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i production site.yml -K
#Alternatively, depending on hosts defined in production file
ansible-playbook -i production bare_metal.yml -K
```

If hosts are docker containers that are running on local host, you may use docker_play.sh

```sh
./docker_play.sh
```
