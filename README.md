# Ansible-Kubernetes-Deployment
This repo contain the ansible playbook and shell script to create Kubernetes Cluster on AWS Cloud through Ansible.

### Requirement
- AWS Account
- Ansible installed in laptop
- Aws IAM user access and secret key
- Aws key-pair

## Install Ansible
Update system and install dependency 
```
sudo apt-get update -y
sudo apt install software-properties-common -y
```
Add repo via PPA
```
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install python3
sudo apt install ansible -y
sudo apt install ansible-core -y
```
Install ```pip```,```boto3```, and ```ansible-galaxy``` if not present in system.
```
apt install python3-pip
sudo apt-get install python3-boto3
ansible-galaxy collection list
ansible-galaxy collection install amazon.aws
```
---
### Git Checkout
```
git clone https://github.com/merajaprasad/ansible-kubernetes-deployment.git
cd ansible-kubernetes-deployment
```
### Configure Credentials
Now we have to configure our aws access key and secret access key in aws vault to provision instances
```
# Create Password for vault
openssl rand -base64 2048 > vault.pass             # vault.pass is can be any name

# Add your credentials using the below vault command
ansible-vault create group_vars/all/pass.yml --vault-password-file vault.pass

ansible-vault edit group_vars/all/pass.yml --vault-password-file vault.pass
```

### Create Instances
copy below ansible playbook file and change required details as per your aws account, ```pem-key```, ```region```, ```security-group```, and ```image-id```.
```
---
- name: creating ec2 instances
  hosts: localhost
  connection: local
  gather_facts: yes
  vars:
    instance_type: "t2.medium"
    region: "us-east-1"

  tasks:
    - name: start an instance with a public IP address
      amazon.aws.ec2_instance:
        name: "{{item.name}}"
        key_name: "kubernetes"
        instance_type: "{{instance_type}}"
        region: "{{region}}"
        security_group: launch-wizard-1
        network_interfaces:
          - assign_public_ip: true
        image_id: "{{item.image}}"
        tags:
          environment: "{{item.name}}"        # we can change tags also

        aws_access_key: "{{aws_access_key}}"  # variable from vault as defined
        aws_secret_key: "{{aws_secret_key}}"  # variable from vault as defined

      loop:
        - { image: "ami-005fc0f236362e99f", name: "Kubernetes-Master"}   # ubuntu 22
        - { image: "ami-005fc0f236362e99f", name: "Kubernetes-Node"}     # ubuntu 22

```
### Execute above playbook using below command
Run below to validate or dry run the playbook
```
ansible-playbook <file-name>.yml --vault-password-file vault.pass --check
```
Execute below command to Create Instances
```
ansible-playbook <file-name>.yml --vault-password-file vault.pass
```
Now check in aws console, whether the Instances got created or Not. then copy the public IP address and paste in Inventory.ini file.

### Set Password Less Authentication
Run below command on local system
```
ssh-keygen
ssh-copy-id -f "-o IdentityFile <path-of-pem-key>/<keypair-name.pem>" ubuntu@<instance-public-ip>

# now connect with ssh
ssh ubuntu@<instance-public-ip>
```

## Execute playbooks
Now go inside ansible-kubernetes-deployment directory and Execute all the ansible playbook using below command.
```
ansible-playbook install_softwares.yml -i inventory.ini --vault-password-file vault.pass
ansible-playbook initialize_master.yml -i inventory.ini --vault-password-file vault.pass
```
now run below command to copy the updated file into your system
```
scp -i <keypair-name.pem> ubuntu@<instance-public-ip>:/home/ubuntu/join-node.sh ./join-node.sh
```
```
ansible-playbook join_node.yml -i inventory.ini --vault-password-file vault.pass
ansible-playbook install_docker.yml -i inventory.ini --vault-password-file vault.pass
```
### Join command
Run below command on Kubernetes-Master
```
kubeadm token create --print-join-command
```
Run below command on Kubernetes-Node
```
<join-command> --v=5
```
---
