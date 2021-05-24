#!/bin/bash
#
## Ansible playbook generator
#
## v.0.01 - Dennis McCarthy
### www.londoniac.co.uk

#Uncomment below for debugging
#set -x

source controlFile
RUNDIR=/tmp/ansible_files
mkdir $RUNDIR

clearDir ()
{
# Fresh Start
rm -fr $RUNDIR/tasks/*
rm -fr $RUNDIR/run.yml
rm -fr $RUNDIR/templates/*
rm -fr $RUNDIR/group_vars/*
}

ansibleCFG ()
{
# basic ansible.cfg file. Update as required
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
# populate the inventory file with localhost and force python3
echo "localhost ansible_python_interpreter=/usr/bin/python3" > $RUNDIR/inventory
}

checkDirs ()
{
# checks on the DIR structure
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
# create the DIRS and files required
echo "Creating the other directories we need"
mkdir -p $RUNDIR/{tasks,templates,group_vars}
touch $RUNDIR/run.yml
}

startRunYml ()
{
# Start to populate the run.yml
cat << EOF >> $RUNDIR/run.yml
---
- hosts: $hosts
  connection: $connection
  gather_facts: $facts

  tasks:
  handlers:
EOF
}

startGroupVars ()
{
# Start to populate the run.yml
cat << EOF >> $RUNDIR/group_vars/all
---
EOF
}

checkKeyFile ()
{
# while loop to read through the keyFile
# and generates the playbooks/templates
while LST= read -r playbook_name package service template; do

cat << EOF >> $RUNDIR/group_vars/all
${playbook_name}_package: $package
EOF

# Create the playbook with required content
cat << EOF >> $RUNDIR/tasks/$playbook_name.yml
---
- name: install package $package
  package:
    name: "{{ ${playbook_name}_package }}"
    state: present
EOF

# Only add the service if it's in the keyFile
if [ ! -z "$service" ]
then
cat << EOF >> $RUNDIR/tasks/$playbook_name.yml

- name: Enable service $service
  service:
    name: "{{ ${playbook_name}_service }}"
    enabled: yes
    state: started
EOF
cat << EOF >> $RUNDIR/group_vars/all
${playbook_name}_service: $service
EOF
fi

# Only add the template if it's in the keyFile
if [ ! -z "$template" ]
then
cat << EOF >> $RUNDIR/tasks/$playbook_name.yml

- template:
    src: $RUNDIR/templates/$template.j2
    dest: /tmp/$template #Change me for the real location...
  notify:
  -  restart $package
EOF
# Also add the handler as the service will need restarting
# if the template is updated
cat << EOF >> $RUNDIR/run.yml
    - name: restart $package
      service:
        name: $package
        state: restarted
EOF

cat << EOF >> $RUNDIR/templates/$template.j2
<!doctype html>
<title>LondonIAC meetup - Site Maintenance</title>
<style>
  body { text-align: center; padding: 150px; }
  h1 { font-size: 50px; }
  body { font: 20px Helvetica, sans-serif; color: #333; }
  article { display: block; text-align: left; width: 650px; margin: 0 auto; }
  a { color: #dc8100; text-decoration: none; }
  a:hover { color: #333; text-decoration: none; }
</style>

<article>
    <h1>Your Server name is: {{ ansible_hostname }}</h1>
    <div>
        <p>Sorry for the inconvenience but we&rsquo;re performing some maintenance at the moment. If you need to you can always <a href="mailto:#">contact us</a>, otherwise we&rsquo;ll be back online shortly!</p>
<img src="https://marcelorjava.files.wordpress.com/2014/04/dilbert.gif" alt="Dilbert">
        <p>&mdash; The Team</p>
    </div>
    <p>
</p>
</article>
EOF
fi
done < keyFile
}

addTasks ()
{
# Add the playbooks generated to the run.yml file.
for i in `ls  $RUNDIR/tasks`; do sed -i "/tasks:/a\    \- import_tasks- tasks\/$i" $RUNDIR/run.yml; done
sed -i 's/import_tasks-/import_tasks:/g' $RUNDIR/run.yml
ls -al $RUNDIR
}

# Call the functions below:
clearDir
ansibleCFG
inventory
checkDirs
createDirs
startRunYml
startGroupVars
checkKeyFile
addTasks

