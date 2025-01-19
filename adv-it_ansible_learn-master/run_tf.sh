#!/bin/bash

terraform -chdir="$(pwd)/infrastracture" $1 -var-file="env/vars.tfvars"
