#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to check if a Multipass VM is running
check_vm_state() {
    local vm_name=$1
    if multipass info "$vm_name" &>/dev/null; then
        local state=$(multipass info "$vm_name" | grep State | awk '{print $2}')
        if [[ "$state" == "Running" ]]; then
            return 0 # VM is running
            echo "VM is Running State"
        fi
    fi
    return 1 # VM is not running
    echo "VM is NOT running"
}

# --- 1. Launch or ensure Kubernetes VMs are running ---
echo "--- Ensuring Kubernetes VMs are running ---"
VMS=("control-plane" "worker01" "worker02")
for vm in "${VMS[@]}"; do
    if check_vm_state "$vm"; then
        echo "VM '$vm' is already running. Skipping launch."
    else
        echo "Launching VM '$vm'..."
        multipass launch --name "$vm" --cpus 2 --memory 2GB --disk 20GB
    fi
done

# Wait for all VMs to be ready
echo "--- Waiting for all VMs to be ready ---"
multipass list
for vm in "${VMS[@]}"; do
    until check_vm_state "$vm"; do
        echo "Waiting for VM '$vm' to be in Running state..."
        sleep 5
    done
    echo "VM '$vm' is now running."
done
echo "All VMs are now running."
echo

# --- 2. Setup control-plane VM ---
echo "--- Setting up the control-plane VM ---"
multipass exec control-plane -- sudo bash -c '
  sudo apt update -y
  git clone https://github.com/cfkubo/k8s-security.git
  cd k8s-security
  sh k8s.sh
'
# --check for kubectl get nodes status for ready state --   
if multipass exec control-plane -- kubectl get nodes | grep -q 'Ready'; then
    echo "Control-plane node is in Ready state."
else
    echo "Control-plane node is NOT in Ready state. Please check the setup."
    exit 1
fi


echo

# --- 3. Get the kubeadm join command ---
echo "--- Extracting the kubeadm join command from the control-plane ---"
# Transfer the log file from the control-plane to the host
multipass transfer control-plane:k8s-security/k8s-log.txt .

# Extract the join command from the log file
JOIN_COMMAND=$(grep 'kubeadm join' k8s-log.txt -A 1 | sed 's/\\//' | xargs)
echo "Extracted join command:"
echo "$JOIN_COMMAND" 
echo

# --- 4. Setup worker01 VM and join to the cluster ---
echo "--- Setting up worker01 and joining it to the cluster ---"
multipass exec worker01 -- sudo bash -c '
  sudo apt update -y
  git clone https://github.com/cfkubo/k8s-security.git
  cd k8s-security
  sh k8s-worker.sh
'

# Run the join command on the worker node
multipass exec worker01 -- sudo bash -c "sudo $JOIN_COMMAND"
echo "Worker01 has joined the cluster."
echo

# --- 5. Setup worker02 VM and join to the cluster ---
echo "--- Setting up worker02 and joining it to the cluster ---"
multipass exec worker02 -- sudo bash -c '
  sudo apt update -y
  git clone https://github.com/cfkubo/k8s-security.git
  cd k8s-security
  sh k8s-worker.sh
'

# Run the join command on the worker node
multipass exec worker01 -- sudo bash -c "sudo $JOIN_COMMAND"
echo "Worker02 has joined the cluster."
echo

# --- 6. Final check ---


if multipass exec control-plane -- kubectl get nodes | grep -q 'Ready'; then
    echo "All nodes are in Ready state."
else
    echo "Some nodes are NOT in Ready state. Please check the setup."
    exit 1
fi

echo "--- All nodes should now be ready! ---"
echo "To check the cluster status, run the following command:"
echo "multipass exec control-plane -- kubectl get nodes"

multipass transfer control-plane:/home/ubuntu/.kube/config ~/.kube/config

echo "Kubeconfig file has been copied to your local machine at ~/.kube/config"
echo "You can now use kubectl to interact with your Kubernetes cluster."

echo "Setup complete!"



