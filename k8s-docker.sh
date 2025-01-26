# Installation of kubeadm cluster on Ubuntu 22.04 that uses Docker for container orchestration

# 1. Disable swap:
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 2. Test the ports:
# On the server: nc -l 6443
# On the local machine: nc x.x.x.x 6443

# 3. Setup ipv4 bridge on all nodes
# Create config file for modules
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Load modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Create another config file for sysctl
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Apply sysctl parameters
sudo sysctl --system

# 4. Update apt source list
sudo apt-get update
# sudo apt-get upgrade -y

# 5. Install Docker
sudo apt-get install docker.io -y

# 6. Configure Docker to use systemd cgroup driver (recommended for kubeadm)
sudo systemctl enable docker
sudo systemctl daemon-reload

# 7. Install helper tools
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# 8. Download the public signing key for the Kubernetes package repositories
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# 9. Add the Kubernetes apt repository for v1.29
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 10. Update apt source list, install kubelet and kubectl and hold them at the current version
sudo apt-get update
sudo apt-get install -y kubelet kubectl
sudo apt-mark hold kubelet kubectl

# 11. Initialize the cluster with Docker socket (assuming the Docker daemon is running on the default socket path)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --container-runtime docker

# 12. Copy the kubeconfig file to the user's home directory and change the ownership
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 13. Install the Tigera Calico operator and custom resource definitions (Optional - for network policy enforcement)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

# 14. Install Calico by creating the necessary custom resource (Optional - for network policy enforcement)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

# 15. Check the status of the cluster
# kubectl get pods -n calico-system  (if Calico is installed)
kubectl get pods

# 16. Remove the taints on the control plane so that you can schedule pods on it
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# 17. Check the nodes
kubectl get nodes -o wide
