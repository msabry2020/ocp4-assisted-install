#!/bin/bash

# Graceful Cluster Shutdown Script for OpenShift Container Platform 4.17
# Reference: https://docs.openshift.com/container-platform/4.17/backup_and_restore/graceful-cluster-shutdown.html

# Step 1: Mark all the nodes in the cluster as unschedulable
echo "cordon nodes..."
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}'); do echo ${node} ; oc adm cordon ${node} ; done

# Step 2: Evacuate the pods using the following method:
echo "drain nodes..."
for node in $(oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[*].metadata.name}'); do echo ${node} ; oc adm drain ${node} --delete-emptydir-data --ignore-daemonsets=true --timeout=15s --force ; done

# Step 5: Power off  nodes
echo "Powering off nodes..."
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}'); do oc debug node/${node} -- chroot /host shutdown -h 1; done 

echo "Graceful cluster shutdown completed successfully."