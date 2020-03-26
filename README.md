# AnsiblePlaybookGenerator
This script is under construction and will be subject to lots of change...

## Pre-reqs!
 * You must be using ansible 2.4 or above.

The idea is to create a base ansible playbook for your packages, services, templates (including handlers). Think of it as a quick start to getting you up and running with ansible without have to write too much intitally.

## Tested on RHEL8 Ubuntu (Xenial/Bionic) 16/18.04
NOTE: If you run this on older OS's it may get a python issue (it trys to install some python2 packages). Once I do more testing I'll be able to update the script and detect which version is running. If you're running it on earlier OS's, and you get any python issue, try removing the variable from the inventory file and re-running.

### Latest updates:
 * Added (variables) to groups_vars to take the package and service name out of the tasks .yml file.
 * Templates are now supported.
 * Added support for packages that don't have a service. Just leave the service column blank and it won't be added.

### Quick-Start
 * Clone the repo & cd AnsiblePlaybookGenerator
 * run the script: ./AnsiblePlaybookGenerator.sh
 * cd /tmp/ansible_files & run (as root): # ansible-playbook -i inventory run.yml
 * Watch the playbook run and install nginx, curl, wget & vsftp.
 * Now have a look around at ansible playbooks, templates & group_vars - enjoy :)
 
### How to run it (more detail):
 * Clone this repo.
 * CD into the AnsiblePlaybookGenerator directory.
 * Check the script so you know it's safe [don't trust me!]
 * Make changes to the keyFile. In this order:
````
 I.E: (you don;t need to space them out in columns, just a space between them is enough)
 [playbook_name] [package] [service] [template] #<-- this is and example line and not in the actual keyFile.
 webserver       nginx     nginx     index.html
 vsftpd vsftpd vsftpd
 wget wget
 curl curl
 ADD MORE...
````
 * Run the script.
 * Once the script has run, it will create a new directory /tmp/ansible_files with the structure and files in place. CD into this directory.
 * The script creates a local inventory file with vars to enforce the python3 interpreter.
 * The script creates you a local ansible.cfg file with some base options.
 * The script creates a run.yml file including tasks from the tasks directory (and home to the handlers).
 * Once the script has finished, you will still need to populate any template files you added and also select the destination you want the file to be copied over to.
 * As you make those updates, re-running ansible will enforce them.
 
### Running the script (for localhost):
The ansible code only builds for localhost right now. I'm thinking about providing a config file that can store the options you need to build the correct ansible code for your use-case. I.E. remote servers, but I'll get on to that shortly.

 * Run as root.

Run the playbook and it will install and setup the packages you added into the keyFile.

I.E:
````
$ cd ../ansible_files/
$ ansible-playbook -i inventory run.yml

PLAY [localhost] **********************************************************************

TASK [Gathering Facts] ****************************************************************
ok: [localhost]

TASK [install package curl] ***********************************************************
changed: [localhost]

TASK [install package vsftpd] *********************************************************
changed: [localhost]

TASK [Enable service vsftpd] **********************************************************
ok: [localhost]

TASK [install package nginx] **********************************************************
changed: [localhost]

TASK [Enable service nginx] ***********************************************************
ok: [localhost]

TASK [template] ***********************************************************************
ok: [localhost]

TASK [install package wget] ***********************************************************
changed: [localhost]

PLAY RECAP ****************************************************************************
localhost                  : ok=8    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


$ systemctl -a | egrep "nginx|vsftp"
  nginx.service           loaded    active   running   A high performance web server and a reverse proxy server
  vsftpd.service          loaded    active   running   vsftpd FTP server                                 

````

### What it does:
Currently it only installs packages, sets up the services & templates, adds a handler to restart the service if the template changes and sets up variables in group_vars for package and service names. I'll be adding additional functionality when I get the time and will try to make it even more useful as I update it.

### Run the script (for remote hosts)
This works with a quick update to the run.yml file. Change the localhost to All (or whatever group you are using in the inventory file)

This:
````
$ cat run.yml
---
- hosts: localhost
  connection: local
````
Becomes:
````
$ cat run.yml
---
- hosts: all

````

If you run the playbook remotely, you can add various options to login to the remote server. For me, I setup SSH keys and just select the user by adding -u ubuntu on to the end of the playbook command.

````
$ ansible-playbook -i inventory run.yml -u ubuntu
````

Checkout privilege escalation for more information on the docs.ansible website. 

### Future updates (wish-list)

 * It now works for templates
 * If it could be adapted for roles and profiles, that would be very handy.
  * This would mean using conditionals and would need a bit of a re-think.
 * Cater for variables or move hardcoded items into group_vars and reference them automatically - DONE
 * Possibly create a limited number of local facts depending on whats useful. This will probably be specific to the use-case.
 * Migrate the script over to python3!
