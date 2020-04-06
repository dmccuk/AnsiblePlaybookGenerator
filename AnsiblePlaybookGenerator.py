import shutil
import os

PATH = "/tmp/ansible_files"
ANSIBLE_CONFIG_TEMPLATE = """[default]
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
timeout = 10"""


def ParseKeyFile():
    playbook_name, package, service, template = ([] for i in range(4))
    with open("keyFile") as myfile:
        for line in myfile:
            try:
                playbook_name.append(line.split()[0])
                package.append(line.split()[1])
                service.append(line.split()[2])
                template.append(line.split()[3])
            except IndexError:
                pass
        return (playbook_name, package, service, template)


def ParseControlFile():
    myvars = {}
    with open("controlFile") as myfile:
        for line in myfile:
            li = line.strip()
            if not li.startswith("#") and not line.isspace():
                name, var = line.partition("=")[::2]
                myvars[name.rstrip()] = var.replace("\n", "")
    return myvars


def CheckPath(path):
    if os.path.isdir(path):
        print(f"Directory {path} Exists")
    else:
        print(f"Creating Directory {path}")
        os.makedirs(path)


def CleanUp(path):
    for filename in os.listdir(f"{path}/"):
        file_path = os.path.join(path, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print("Failed to delete %s. Reason: %s" % (file_path, e))


def CreateAll(path):
    suffixes = ["/tasks", "/templates", "/group_vars"]
    for suffix in suffixes:
        os.makedirs(f"{path}{suffix}")


def AnsibleCfg(path, config):
    with open(f"{path}/ansible.cfg", "w+") as ansibleconfig:
        ansibleconfig.write(config)


def Inventory(path):
    with open(f"{path}/inventory", "w+") as inventory:
        inventory.write("localhost ansible_python_interpreter=/usr/bin/python3")


def RunYml(path, config):
    with open(f"{path}/run.yml", "w+") as run:
        run.write(config)


def GroupVarsTemplate(keyfile):
    config = "---\n"
    lenkeyfile = len(keyfile[0])
    for i in range(lenkeyfile):
        try:
            config = config + f"{keyfile[0][i]}_package: {keyfile[1][i]}\n"
            config = config + f"{keyfile[0][i]}_service: {keyfile[2][i]}\n"
        except IndexError:
            pass
    return config.strip()


def GroupVars(path, config):
    with open(f"{path}/group_vars/all", "w+") as groupvars:
        groupvars.write(config)


def PlaybookNameTemplate(path, keyfile, index):
    try:
        config = f"""---
- name: install package {keyfile[1][index]}
  package:
    name: "{{{{ {keyfile[0][index]}_package }}}}"
    state: present"""
        config = (
            config
            + f"""

- name: Enable service {keyfile[2][index]}
  service:
    name: "{{{{ {keyfile[0][index]}_service }}}}"
    enabled: yes
    state: started

- template:
    src: {path}/templates/{keyfile[3][index]}.j2
    dest: /tmp/{keyfile[3][index]} #Change me for the real location...
  notify:
  -  restart {keyfile[1][index]}"""
        )
    except IndexError:
        pass
    return config


def RunYmlTemplate(controlfile, keyfile):
    config = f"""---
- hosts: {controlfile['hosts']}
  connection: {controlfile['connection']}
  gather_facts: {controlfile['facts']}

  tasks:
  handlers:"""
    for i in range(len(keyfile[2])):
        config = (
            config
            + f"""
    - name: restart {keyfile[1][i]}
      service:
        name: {keyfile[1][i]}
        state: restarted"""
        )
    return config


def PlaybookWrite(path, config, name):
    with open(f"{path}/tasks/{name}.yml", "w+") as playbook:
        playbook.write(config)


CleanUp(PATH)
CheckPath(PATH)
CreateAll(PATH)
keyVars = ParseKeyFile()
controlVars = ParseControlFile()
RUN_YML_TEMPLATE = RunYmlTemplate(controlVars, keyVars)
GROUP_VARS_TEMPLATE = GroupVarsTemplate(keyVars)
for i in range(len(keyVars)):
    PLAYBOOK_CONFIG = PlaybookNameTemplate(PATH, keyVars, i)
    PlaybookWrite(PATH, PLAYBOOK_CONFIG, keyVars[0][i])
AnsibleCfg(PATH, ANSIBLE_CONFIG_TEMPLATE)
Inventory(PATH)
RunYml(PATH, RUN_YML_TEMPLATE)
GroupVars(PATH, GROUP_VARS_TEMPLATE)

# Notes - In this program, things are either being created, updated or deleted. Might be worth making a Class for each case - to refactor.
# A lot happens to RunYml file, can it be done in one place?
# Path is used by everything, keen to refactor that out
# My write functions are extremely shallow functions
