# Portainer in Proxmox

## Run Terraform to provision LXC container
Install transcrypt to decrypt config.pg.tfbackend before initializing terraform
```
terraform init --backend-config=config.pg.tfbackend 
terraform plan
terraform apply
```

## Run Ansible to install Nginx Proxy Manager
### Install Terraform Collection for Ansible
ansible-galaxy collection install cloud.terraform

### Print Terraform Inventory
ansible-inventory -i ./ansible/inventory.yaml --graph --vars

### Run Ansible Playbook
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbook.yaml

### SSH into container
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .ssh/my-private-key.pem root@192.168.254.213

### Download terraform state from backend
terraform state pull > terraform.tfstate

### View terraform state
terraform show -json

### Default Administrator User
Email:    admin@example.com
Password: changeme

https://github.com/elasticdog/transcrypt