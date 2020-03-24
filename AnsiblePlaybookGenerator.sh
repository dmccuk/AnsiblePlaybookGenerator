#!/bin/bash
#
## Ansible playbook generator
#
## v.0.01

RUNDIR=/opt/ansible_files

clearDir ()
{
rm -fr $RUNDIR/tasks/*
rm -fr $RUNDIR/run.yml
}

ansibleCFG ()
{
if [ -f "$RUNDIR/ansible.cfg" ]
then
    echo " ** OK: ansible.cfg exists. **"
else
    echo " ** Error: No ansible.cfg. **"
    echo " **     Creating now... **"
    cat << EOF >> $RUNDIR/ansible.cfg
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
echo "localhost ansible_python_interpreter=/usr/bin/python3" > $RUNDIR/inventory
}

questions ()
{
echo ""
echo "Put all the files in the $RUNDIR DIR:"
if [ -d "$RUNDIR" ]
then
    echo " ** OK: Directory $RUNDIR exists. **"
else
    echo " ** Error: Directory $RUNDIR does not exists. **"
    echo " **     Creating now... **"
    mkdir $ansible_path

fi
}

createDirs ()
{
echo "Creating the other directories we need"
mkdir -p $RUNDIR/{tasks,templates,files,group_vars}
touch $RUNDIR/{packages,users,templates,run.yml}

ls -al $RUNDIR
}

startRunYml ()
{
cat << EOF >> $RUNDIR/run.yml
---
- hosts: localhost
  connection: local

  tasks:
EOF
}

grabPackagesServices ()
{
cat << EOF >> $RUNDIR/tasks/packages_services.yml
---
- name: install package
  package:
    name:
EOF
while LST= read -r package service; do
echo "      - "$package >> $RUNDIR/tasks/packages_services.yml
done < $RUNDIR/packages
echo "    state: present" >> $RUNDIR/tasks/packages_services.yml

cat << EOF >> $RUNDIR/tasks/packages_services.yml
- name: Enable service
  service:
    name: "{{ item }}"
EOF

echo "    enabled: yes" >> $RUNDIR/tasks/packages_services.yml
echo "    state: started" >> $RUNDIR/tasks/packages_services.yml
echo "  with_items:" >> $RUNDIR/tasks/packages_services.yml
while LST= read -r package service; do
echo "    - $service" >> $RUNDIR/tasks/packages_services.yml
done < $RUNDIR/packages


}


addTasks ()
{
for i in `ls  $RUNDIR/tasks`; do echo "    - "import_tasks: tasks/$i >> $RUNDIR/run.yml; done
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
# ** Break the file holding the information into - playbook name, package, service, template **
# templates to hold config files.
# Do i make one big play book to start?
# then add in seperate playbooks for each "thing" you want to do.
# What should i do about variables?
# Do i also want to generate local facts? so information about a host
# I can add to a vars file to make playbooks run on lots of different hosts?

