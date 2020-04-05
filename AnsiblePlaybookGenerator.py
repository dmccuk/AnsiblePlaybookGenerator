import shutil
import os

PATH = '/tmp/ansible_files'
CONFIG_TEMPLATE ="""[default]
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
    shutil.rmtree(path+'/tasks')
    shutil.rmtree(path+'/templates')
    shutil.rmtree(path+'/group_vars')
    os.remove(path+'/run.yml')


def AnsibleCfg(path, config):
    if os.path.isfile(path+'ansible.cfg'):
        print("Config Exists")
    else:
        with open(f'{path}/ansible.cfg', 'w') as ansibleconfig:
            ansibleconfig.write(config)


CleanUp(PATH)
AnsibleCfg(PATH, CONFIG_TEMPLATE)
