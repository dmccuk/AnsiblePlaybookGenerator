#!/bin/bash
#
## Ansible playbook generator
#
## v.0.01



clearDir ()
{
rm -fr /tmp/ansible_files/tasks/*
rm -fr /tmp/ansible_files/run.yml
}

ansibleCFG ()
{
if [ -f "/tmp/ansible_files/ansible.cfg" ]
then
    echo " ** OK: ansible.cfg exists. **"
else
    echo " ** Error: No ansible.cfg. **"
    echo " **     Creating now... **"
    cat << EOF >> /tmp/ansible_files/ansible.cfg
[default]
timeout=10
private_key_file = ~/.ssh/id_rsa
host_key_checking = False

[privilege_escalation]
become = yes
become_method = sudo
become_user = root
become_ask_path = False

[ssh_connection]
scp_if_true = True
timeout = 10
EOF
fi
}

inventory ()
{
echo "localhost ansible_python_interpreter=/usr/bin/python3" > /tmp/ansible_files/inventory
}

questions ()
{
echo ""
echo "Put all the files in the /tmp/ansible_files DIR:"
if [ -d "/tmp/ansible_files" ]
then
    echo " ** OK: Directory /tmp/ansible_files exists. **"
else
    echo " ** Error: Directory /tmp/ansible_files does not exists. **"
    echo " **     Creating now... **"
    mkdir $ansible_path

fi
}

createDirs ()
{
echo "Creating the other directories we need"
mkdir -p /tmp/ansible_files/{tasks,templates,files,group_vars}
touch /tmp/ansible_files/{packages,users,templates,run.yml}

ls -al /tmp/ansible_files
}

startRunYml ()
{
cat << EOF >> /tmp/ansible_files/run.yml
---
- hosts: localhost
  connection: local

  tasks:
EOF
}

grabPackagesServices ()
{
cat << EOF >> /tmp/ansible_files/tasks/packages_services.yml
---
- name: install package
  package:
    name:
EOF
while LST= read -r package service; do
echo "      - "$package >> /tmp/ansible_files/tasks/packages_services.yml
done < /tmp/ansible_files/packages
echo "    state: present" >> /tmp/ansible_files/tasks/packages_services.yml

cat << EOF >> /tmp/ansible_files/tasks/packages_services.yml
- name: Enable service
  service:
    name: "{{ item }}"
EOF

echo "    enabled: yes" >> /tmp/ansible_files/tasks/packages_services.yml
echo "    state: started" >> /tmp/ansible_files/tasks/packages_services.yml
echo "  with_items:" >> /tmp/ansible_files/tasks/packages_services.yml
while LST= read -r package service; do
echo "    - $service" >> /tmp/ansible_files/tasks/packages_services.yml
done < /tmp/ansible_files/packages


}


addTasks ()
{
for i in `ls  /tmp/ansible_files/tasks`; do echo "    - "import_tasks: tasks/$i >> /tmp/ansible_files/run.yml; done
}


clearDir
ansibleCFG
inventory
questions
createDirs
startRunYml
grabPackagesServices
addTasks



# Create directory structure {ansible/ansible.cfg/plays dir/inventory?}
# start with a basic playbook. Look at simple jobs
# break the files into packages, services (including handler to restart)
# templates to hold config files.
# Do i make one big play book to start?
# then add in seperate playbooks for each "thing" you want to do.
# What should i do about variables?
# Do i also want to generate local facts? so information about a host
# I can add to a vars file to make playbooks run on lots of different hosts?

