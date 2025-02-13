# ocp4-assisted-install
sh pre.sh
ansible-playbook -i ansible/inventory playbook.yml
cd terraform
terraform init
terraform apply