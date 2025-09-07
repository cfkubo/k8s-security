#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# =========================================================================
# === CONFIGURATION =======================================================
# =========================================================================

# Set the number of worker nodes you want to create.
# The script will create worker01, worker02, ... up to this number.
NUM_WORKERS=3

# =========================================================================
# === SCRIPT START ========================================================
# =========================================================================

current_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "Script started at: $current_time"

# Function to check if a Multipass VM is running
check_vm_state() {
    local vm_name=$1
    if multipass info "$vm_name" &>/dev/null; then
        local state=$(multipass info "$vm_name" | grep State | awk '{print $2}')
        if [[ "$state" == "Running" ]]; then
            return 0 # VM is running
        fi
    fi
    return 1 # VM is not running
}

# --- 1. Launch or ensure Kubernetes VMs are running ---
echo "--- Ensuring Kubernetes VMs are running ---"

# Dynamically build the list of all VMs (control-plane and workers)
VMS=("control-plane")
for i in $(seq 1 $NUM_WORKERS); do
    VMS+=("worker$(printf "%02d" $i)")
done

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
multipass list
echo
echo "All VMs are now running."
sleep 30
multipass list
echo

# --- 2. Setup control-plane VM ---
echo "--- Setting up the control-plane VM ---"
multipass exec control-plane -- sudo bash -c '
  sudo apt update -y
  sleep 30
  git clone https://github.com/cfkubo/k8s-security.git
  cd k8s-security
  sh k8s.sh
'
# --check for kubectl get nodes status for ready state --
echo "Waiting for control-plane node to become Ready..."

while ! multipass exec control-plane -- sudo kubectl wait --for=condition=Ready node/control-plane --timeout=300s; do
    echo "." # Print a dot for each failed check
    sleep 5      # Wait for 5 seconds before checking again
done

multipass exec control-plane -- sudo bash -c "kubectl get nodes -o wide"

echo
echo "Control-plane node is in Ready state. HURRAH! HURRAH! HURRAH!"
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

# --- 4. Setup worker VMs and join to the cluster ---
echo "--- Setting up worker VMs and joining them to the cluster ---"
for i in $(seq 1 $NUM_WORKERS); do
    worker_name="worker$(printf "%02d" $i)"
    echo "--- Setting up $worker_name and joining it to the cluster ---"
    multipass exec "$worker_name" -- sudo bash -c '
        sudo apt update -y
        git clone https://github.com/cfkubo/k8s-security.git
        cd k8s-security
        sh k8s-worker.sh
    '
    sleep 5 # Give some time before running the join command
    echo "Running join command on $worker_name..."
    # Run the join command on the worker node
    multipass exec "$worker_name" -- sudo bash -c "sudo $JOIN_COMMAND"
    echo "$worker_name has joined the cluster. HURRAH! HURRAH! HURRAH!"
    echo
done

# --- 5. Final check ---
echo "--- Performing final check on all nodes ---"
# Loop until all nodes are "Ready"
while !  multipass exec control-plane -- sudo kubectl wait --for=condition=Ready node/control-plane --timeout=300s; do
    echo "." # Print a dot for each failed check
    sleep 5      # Wait for 5 seconds before checking again
done

# The above check is not 100% accurate for all nodes, let's wait a bit longer for all to fully join
echo "Giving the nodes a little more time to finalize the join..."
sleep 15
multipass exec control-plane -- sudo bash -c "kubectl get nodes -o wide"
echo "All nodes are in Ready state. HURRAH! HURRAH! HURRAH!"

echo "--- All nodes should now be ready! ---"
echo "To check the cluster status, run the following command:"

multipass exec control-plane -- sudo bash -c "kubectl get nodes -o wide"

# Copy kubeconfig file to local machine for local kubectl access
# This is a more robust way to copy the file than 'multipass transfer'
multipass exec control-plane -- sudo bash -c "cat /etc/kubernetes/admin.conf" > ~/.kube/config

echo "Kubeconfig file has been copied to your local machine at ~/.kube/config"
echo "You can now use kubectl to interact with your Kubernetes cluster."

echo "Setup complete!"

end_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "Script ended at: $end_time"

# Fix for "date: illegal option -- d" error on macOS
end_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$end_time" +%s)
current_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$current_time" +%s)

TotalTime=$(( end_timestamp - current_timestamp ))
echo "Total time taken: $TotalTime seconds"

echo "HURRAH! HURRAH! HURRAH! All done!"
