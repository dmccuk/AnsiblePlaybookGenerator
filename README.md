# AnsiblePlaybookGenerator
This script is under construction and will be subject to lots of change...

## Pre-reqs!
 * You must be using ansible 2.4 or above.

The idea is to create a base ansible playbook for your packages, services, templates (including handlers). Think of it as a quick start to getting you up and running with ansible without have to write too much intitally.

## Only tested on RHEL 8 & Ubuntu (Bionic) 18.04.
If you run this on older OS's it may get a python issue (it trys to install some python2 packages). Once I do more testing I'll be able to update the script and detect which version is running. If you're running it on earlier OS's, and you get any python issue, try removing the variable from the inventory file and re-running.

### How to run it:
 * Clone this repo.
 * CD into the AnsiblePlaybookGenerator directory.
 * Check the script so you know it's safe [don't trust me!]
 * Makes changes to the keyFile. In this order:
````
 I.E:
 [playbook_name] [package] [service] [template]
 webserver       nginx     nginx     index.html
 system_profile  tuned     tuned
 ADD MORE...
````
 * Run the script.
 * Once the script has run, it will create a new directory in /tmp/ansible_files. CD into this directory.
 * The script creates a local inventory file with the RHEL8 vars to enforce the python3 interpreter.
 * The script creates you a local ansible.cfg file with some base options.
 * The script creates a run.yml file including tasks from the tasks directory.
 * Once the script has finished, you will still need to populate any template files you added and also select the destination you want the file to be copied over to.
 * As you make those updates, running ansible will enforce them.
 
### Running the script:
The ansible code only builds for localhost right now. I'm thinking about providing a config file that can store the options you need to build the correct ansible code for your use-case.

Run the playbook and it will install and setup the packages you added into the keyFile.

I.E:
````
# cd ../ansible_files/
[root:rhsca1.example.com:/opt/ansible_files ~]# ansible-playbook -i inventory run.yml

PLAY [localhost] **********************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [localhost]

TASK [install package tuned] **********************************************************************************************************
changed: [localhost]

TASK [Enable service tuned] ***********************************************************************************************************
changed: [localhost]

TASK [install package nginx] **********************************************************************************************************
changed: [localhost]

TASK [Enable service nginx] ***********************************************************************************************************
changed: [localhost]

TASK [template] ***********************************************************************************************************************
ok: [localhost]

PLAY RECAP ****************************************************************************************************************************
localhost                  : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[/opt/ansible_files ~]#
[/opt/ansible_files ~]# rpm -qa | egrep "nginx|tuned"
nginx-mod-stream-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-mod-http-perl-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
tuned-2.12.0-3.el8_1.1.noarch
nginx-mod-http-xslt-filter-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-mod-mail-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-mod-http-image-filter-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-all-modules-1.14.1-9.module+el8.0.0+4108+af250afe.noarch
nginx-filesystem-1.14.1-9.module+el8.0.0+4108+af250afe.noarch

[/opt/ansible_files ~]# systemctl -a |  egrep "nginx|tuned"
  ksmtuned.service                                                                                               loaded    active   running   Kernel Samepage Merging (KSM) Tuning Daemon
  nginx.service                                                                                                  loaded    active   running   The nginx HTTP and reverse proxy server
  tuned.service                                                                                                  loaded    active   running   Dynamic System Tuning Daemon
[root:rhsca1.example.com:/opt/ansible_files ~]#                                               
````

### What it does:
Currently it only updates packages, services & templates. I'll be adding additional functionality when i get the time and will try to make it more useful as I update it.

### Future updates (wish-list)

 * Make it Work for templates and any other useful configuration.
 * If it could be adapted for roles and profiles, that would be very handy.
 * Can cater for variables or move hardcoded items into group_vars and reference them.
 * possibly create a limited number of local facts depending on whats useful. This will probably be function specific to an add on wourl be good.
 * Migrate the script over to python3!
