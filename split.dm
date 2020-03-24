#!/bin/bash

rm -fr tasks/*

while LST= read -r playbook_name package service template; do
touch tasks/$playbook_name.yml
echo "This is the playbook: "$playbook_name >> tasks/$playbook_name.yml
echo "This is the package: "$package >> tasks/$playbook_name.yml
echo "This is the service: "$service >> tasks/$playbook_name.yml
if [ ! -z "$template" ]
then
  echo "This is the template: "$template >> tasks/$playbook_name.yml
fi
done < keyFile
