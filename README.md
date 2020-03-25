# AnsiblePlaybookGenerator
This script is under construction and will be subject to lots of change...

The ides is to create a base ansible playbook for your packages, services, templates and users. Think of it as a quick start to getting you up and running with ansible without have to write too much.

## Only tested on RHEL 8 & Ubuntu (Bionic) 18.04.
IF you run this on older OS's it may get a python issue. Once I do more testing I'll be able to update the script and detect which version is running. If you're running it on earlier OS'd, and you get any python issue, try removing the variable from the inventory file and re-running.

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
 * The script creates you a local ansile.cfg file with some base options.
 * Run the script again. This time it will create the finished tasks and run.yaml with your updated info.
 
### Running the script:
The ansible code only builds for localhost right now. I'm thinking about providing a config file that can store the options you need to build the correct ansible code for your use-case.

run the playbook and it will install whatever packages you listed in the packages file and also enable and start the services.

I.E:
````
# ansible-playbook -i inventory run.yml

PLAY [localhost] *********************************************************************************************

TASK [Gathering Facts] ***************************************************************************************
ok: [localhost]

TASK [install package] ***************************************************************************************
changed: [localhost]

TASK [Enable service] ****************************************************************************************
changed: [localhost] => (item=tuned)
changed: [localhost] => (item=nginx)

PLAY RECAP ***************************************************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

[root:rhsca1.example.com:/tmp/ansible_files ~]# rpm -qa | egrep "nginx|tuned"
nginx-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-mod-stream-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-filesystem-1.14.1-9.module+el8.0.0+4108+af250afe.noarch
nginx-mod-http-perl-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-mod-http-xslt-filter-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-mod-mail-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
nginx-mod-http-image-filter-1.14.1-9.module+el8.0.0+4108+af250afe.x86_64
tuned-2.12.0-3.el8_1.1.noarch
nginx-all-modules-1.14.1-9.module+el8.0.0+4108+af250afe.noarch
[root:rhsca1.example.com:/tmp/ansible_files ~]# systemctl -a |  egrep "nginx|tuned"
  ksmtuned.service                                                                                               loaded    active   running   Kernel Samepage Merging (KSM) Tuning Daemon                                   
  nginx.service                                                                                                  loaded    active   running   The nginx HTTP and reverse proxy server                                       
  tuned.service                                                                                                  loaded    active   running   Dynamic System Tuning Daemon                                                  
````

### What it does:
Currently it only updates packages and services. I'll be adding additional functionality when i get the time and will try to make it more useful as I update it.

### Future updates (wish-list)

 * Make it Work for templates and any other useful configuration.
 * If it could be adapted for roles and profiles, that would be very handy.
 * Can cater for variables or move hardcoded items into group_vars and reference them.
 * possibly create a limited number of local facts depending on whats useful. This will probably be function specific to an add on wourl be good.
 * Migrate the script over to python3!
