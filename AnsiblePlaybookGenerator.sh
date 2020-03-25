#!/bin/bash
#
## Ansible playbook generator
#
## v.0.01 - Dennis McCarthy
### www.londoniac.co.uk

#Uncomment below for debugging
#set -x

RUNDIR=/tmp/ansible_files
mkdir $RUNDIR

clearDir ()
{
rm -fr $RUNDIR/tasks/*
rm -fr $RUNDIR/run.yml
rm -fr $RUNDIR/templates/*
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
echo "Putting all the files in the $RUNDIR DIR:"
if [ -d "$RUNDIR" ]
then
    echo " ** OK: Directory $RUNDIR exists. **"
else
    echo " ** Error: Directory $RUNDIR does not exists. **"
    echo " **     Creating now... **"
    mkdir $RUNDIR

fi
}

createDirs ()
{
echo "Creating the other directories we need"
mkdir -p $RUNDIR/{tasks,templates}
touch $RUNDIR/run.yml
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

checkKeyFile ()
{
# while loop to read through the keyFile
while LST= read -r playbook_name package service template; do
cat << EOF >> $RUNDIR/tasks/$playbook_name.yml
# Create the playbook with required content
---
- name: install package $package
  package:
    name: $package
    state: present

- name: Enable service $service
  service:
    name: $service
    enabled: yes
    state: started
EOF

if [ ! -z "$template" ]
then
cat << EOF >> $RUNDIR/tasks/$playbook_name.yml

- template:
    src: $RUNDIR/templates/$template.j2
    dest: /tmp/$template #Change me for the real location...
  notify:
  -  restart $package
EOF

cat << EOF >> $RUNDIR/run.yml
  handlers:
    - name: restart $package
      service:
        name: $package
        state: restarted
EOF
echo "Add stuff to me!" >> $RUNDIR/templates/$template.j2
fi
# The keyFile is in the same DIR at the AnsiblePlaybookGenerator script.
done < keyFile
}

addTasks ()
{
#for i in `ls  $RUNDIR/tasks`; do echo "    - "import_tasks: tasks/$i | >> $RUNDIR/run.yml; done
for i in `ls  $RUNDIR/tasks`; do sed -i "/handlers:/i\    \- import_tasks: tasks\/$i" $RUNDIR/run.yml; done
ls -al $RUNDIR
}


clearDir
ansibleCFG
inventory
questions
createDirs
startRunYml
checkKeyFile
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

