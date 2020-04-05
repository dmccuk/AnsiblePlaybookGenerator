import shutil
import os

PATH = '/tmp/ansible_files'

def CleanUp(path):
    shutil.rmtree(path+'/tasks')
    shutil.rmtree(path+'/templates')
    shutil.rmtree(path+'/group_vars')
    os.remove(path+'/run.yml')

CleanUp(PATH)
