import shutil
import os

PATH = '/tmp/ansible_files'
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


def ParseControlFile():
    myvars = {}
    with open("controlFile") as myfile:
        for line in myfile:
            li = line.strip()
            if not li.startswith("#") and not line.isspace():
                name, var = line.partition("=")[::2]
                myvars[name.rstrip()] = var.replace('\n', '')
    return myvars


def CheckPath(path):
    if os.path.isdir(path):
        print(f"Directory {path} Exists")
    else:
        print(f"Creating Directory {path}")
        os.makedirs(path)


def CleanUp(path):
    for filename in os.listdir(f'{path}/'):
        file_path = os.path.join(path, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))


def CreateAll(path):
    suffixes = ['/tasks', '/templates', '/group_vars']
    for suffix in suffixes:
        os.makedirs(f'{path}{suffix}')


def AnsibleCfg(path, config):
    with open(f'{path}/ansible.cfg', 'w+') as ansibleconfig:
        ansibleconfig.write(config)


def Inventory(path):
    with open(f'{path}/inventory', 'w+') as inventory:
        inventory.write('localhost ansible_python_interpreter=/usr/bin/python3')


def RunYml(path, config):
    with open(f'{path}/run.yml', 'w+') as run:
        run.write(config)


controlVars = ParseControlFile()
RUN_YML_TEMPLATE = f"""---
- hosts: {controlVars['hosts']}
  connection: {controlVars['connection']}
  gather_facts: {controlVars['facts']}
  tasks:
  handlers:"""

CheckPath(PATH)
CleanUp(PATH)
CreateAll(PATH)
AnsibleCfg(PATH, ANSIBLE_CONFIG_TEMPLATE)
Inventory(PATH)
RunYml(PATH, RUN_YML_TEMPLATE)

# Notes - In this program, things are either being created, updated or deleted. Might be worth making a Class for each case - to refactor.
# A lot happens to RunYml file, can it be done in one place?
# Path is used by everything, keen to refactor that out
