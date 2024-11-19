#!/bin/bash
sudo kubeadm config images pull

sudo kubeadm init

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config


# Network Plugin = calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml

# run below command to get the token
NEW_JOIN_TOKEN=$(kubeadm token create --print-join-command)

# Print the join token for verification
echo "New Join Token Command:"
echo "$NEW_JOIN_TOKEN"

# Extract the 'kubeadm join' line and store it in a variable
OLD_JOIN_COMMAND=$(grep "^kubeadm join" node-join.sh)
echo "Old Join Command:"
echo "$OLD_JOIN_COMMAND"

# Escape special characters from the commands
escaped_old_command=$(printf '%s\n' "$OLD_JOIN_COMMAND" | sed 's/[&/\]/\\&/g')
escaped_new_command=$(printf '%s\n' "$NEW_JOIN_TOKEN --v=5" | sed 's/[&/\]/\\&/g')

# Replced with New token
sed -i "s|$escaped_old_command|$escaped_new_command|g" join-node.sh

echo "The join token has been updated successfully in node-join.sh"
