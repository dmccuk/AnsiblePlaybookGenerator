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


def CleanUp(path):
    shutil.rmtree(f'{path}/tasks')
    shutil.rmtree(f'{path}/templates')
    shutil.rmtree(f'{path}/group_vars')
    os.remove(f'{path}/run.yml')
    os.makedirs(f'{path}/tasks')
    os.makedirs(f'{path}/templates')
    os.makedirs(f'{path}/group_vars')
    open(f'{path}/run.yml', 'a').close()


def AnsibleCfg(path, config):
    if os.path.isfile(f'{path}/ansible.cfg'):
        print("Config Exists")
    else:
        with open(f'{path}/ansible.cfg', 'w') as ansibleconfig:
            ansibleconfig.write(config)


def Inventory(path):
    with open('f{path}/inventory') as inventory:
        inventory.write('localhost ansible_python_interpreter=/usr/bin/python3')


CleanUp(PATH)
AnsibleCfg(PATH, ANSIBLE_CONFIG_TEMPLATE)

#Notes - In this program, things are either being created, updated or deleted. Might be worth making a Class for each case - to refactor.
