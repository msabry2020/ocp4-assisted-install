#!/bin/bash

# Graceful Cluster Shutdown Script for OpenShift Container Platform 4.17
# Reference: https://docs.openshift.com/container-platform/4.17/backup_and_restore/graceful-cluster-shutdown.html

# Variables
MASTER_NODES=("master-0" "master-1" "master-2")  # Replace with your master node hostnames
WORKER_NODES=("worker-0" "worker-1" "odf-0" "odf-1" "odf-2")  # Replace with your worker node hostnames
SSH_KEY="/home/eng_muhammedsabry/.ssh/id_rsa"  # Replace with the path to your SSH private key

# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed."
        exit 1
    fi
}

# Step 1: Drain worker nodes
echo "Draining worker nodes..."
for NODE in "${WORKER_NODES[@]}"; do
    oc adm drain "$NODE" --ignore-daemonsets --delete-emptydir-data --force --timeout=15s #--disable-eviction 
    check_success "Draining node $NODE"
done

# Step 2: Stop kubelet on worker nodes
echo "Stopping kubelet on worker nodes..."
for NODE in "${WORKER_NODES[@]}"; do
    ssh -i "$SSH_KEY" "core@$NODE" "sudo systemctl stop kubelet"
    check_success "Stopping kubelet on $NODE"
done

# Step 3: Stop kubelet on master nodes
echo "Stopping kubelet on master nodes..."
for NODE in "${MASTER_NODES[@]}"; do
    ssh -i "$SSH_KEY" "core@$NODE" "sudo systemctl stop kubelet"
    check_success "Stopping kubelet on $NODE"
done

# Step 4: Power off master nodes
echo "Powering off master nodes..."
for NODE in "${MASTER_NODES[@]}"; do
    ssh -i "$SSH_KEY" "core@$NODE" "sudo shutdown -h now"
    check_success "Powering off $NODE"
done

# Step 5: Power off worker nodes
echo "Powering off worker nodes..."
for NODE in "${WORKER_NODES[@]}"; do
    ssh -i "$SSH_KEY" "core@$NODE" "sudo shutdown -h now"
    check_success "Powering off $NODE"
done

echo "Graceful cluster shutdown completed successfully."
