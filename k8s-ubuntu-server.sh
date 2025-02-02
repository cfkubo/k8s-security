#!/bin/bash

# Update and upgrade system
sudo apt update
sudo apt upgrade -y

# Install required packages
sudo apt install -y docker.io containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update and install Kubernetes components
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Mark Kubernetes packages to prevent automatic upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap (if enabled)
sudo swapoff -a
sudo sed -i '/ swap / s/^\\(.*\\)$/#\\1/g' /etc/fstab

# Initialize the master node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16  #!/bin/bash

# Update and upgrade system
sudo apt update
sudo apt upgrade -y

# Install required packages
sudo apt install -y docker.io containerd.io

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update and install Kubernetes components
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Mark Kubernetes packages to prevent automatic upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap (if enabled)
sudo swapoff -a
sudo sed -i '/ swap / s/^\\(.*\\)$/#\\1/g' /etc/fstab

# Initialize the master node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

# Configure kubectl for the master node
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Join worker nodes (execute on worker nodes)
# sudo kubeadm join <master-ip>:<port> --token <token> --discovery-token-ca-cert-hash <hash> 

# Install CNI plugin (e.g., Calico)
# kubectl apply -f https://docs.projectcalico.io/v3.27/manifests/tigera-operator.yaml

# Verify cluster status
sudo kubectl get nodes

# Configure kubectl for the master node
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Join worker nodes (execute on worker nodes)
# sudo kubeadm join <master-ip>:<port> --token <token> --discovery-token-ca-cert-hash <hash> 

# Install CNI plugin (e.g., Calico)
# kubectl apply -f https://docs.projectcalico.io/v3.27/manifests/tigera-operator.yaml

# Verify cluster status
sudo kubectl get nodes
