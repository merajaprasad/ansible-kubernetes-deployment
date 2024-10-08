# Ansible-Kubernetes-Deployment
This repo contain the ansible playbook and shell script to create Kubernetes Cluster on AWS Cloud through Ansible.

### Requirement
- AWS Account
- Ansible installed in laptop
- Aws IAM user access and secret key
- Aws key-pair

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
copy below ansible playbook file and change required details as per your aws account, pem-key, region, security-group, and image-id.
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
```
ansible-playbook <file-name>.yml --vault-password-file vault.pass
ansible-playbook <file-name>.yml --vault-password-file vault.pass --check
```
### Set Password Less Authentication
```
# on local system
ssh-keygen
ssh-copy-id -f "-o IdentityFile <PATH-TO-PEM-FILE>" ubuntu@<INSTANCE-PUBLIC-IP>

# now connect with ssh
ssh ubuntu@<INSTANCE-PUBLIC-IP>
```

### Execute playbooks
Now Execute all the ansible file using below command.
```
ansible-playbook <yaml-file> -i inventory.ini --vault-password-file vault.pass
```

---