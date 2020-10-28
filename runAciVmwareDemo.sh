#!/bin/sh
cd ./VMWARE
terraform destroy -auto-approve
cd ../ACI/DEMO
terraform destroy -auto-approve
clear
read -p "ACI and VMware plans destroyed - ready to provision infra, hit return to continue" retval
terraform plan
terraform apply -auto-approve
cd ../../VMWARE
terraform plan
terraform apply -auto-approve
echo "STARTING WEB APP"
ansible 10.48.168.190 -a "python3 /home/cisco/app.py" -B 3600 -P 0
