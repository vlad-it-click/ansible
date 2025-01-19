#!/bin/bash

#test
echo "Current_Work_Dir: $(pwd)"

# comment
ansible-playbook lessons/16-lesson/playbook.yml --extra-var "MYHOSTS=prod_servers owner=BatMan"

