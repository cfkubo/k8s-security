# Installation of kubeadm cluster on Ubuntu 22.04
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
sudo apt-get update -y
# sudo apt-get upgrade -y

# 5. Install containerd
# sudo apt-get install containerd -y
# OR if you are planning to also use docker:
sudo apt-get install docker.io -y

# 6. Configure containerd for the cgroup driver used by kubeadm (systemd)
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# 7. Restart and enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# 8. Install helper tools
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# 9. Download the public signing key for the Kubernetes package repositories
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes

# 10. Add the Kubernetes apt repository for v1.30
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 11. Update apt source list, install kubelet, kubeadm and kubectl and hold them at the current version
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# 12. Initialize the cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=all 
#--ignore-preflight-errors=all

# 13. Copy the kubeconfig file to the user's home directory and change the ownership
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 14. Install a pod network add-on (Flannel)
# kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# sudo snap install helm --classic

sudo usermod -aG docker $USER
newgrp docker


# # 14. Install the Tigera Calico operator and custom resource definitions
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/tigera-operator.yaml

# # 15. Install Calico by creating the necessary custom resource. For more information on configuration options available in this manifest
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/custom-resources.yaml

sleep 60

source ../.env

kubectl create secret docker-registry dockerhub-secret --namespace=calico-system --docker-server=https://index.docker.io/v1/ --docker-username=$docker_username --docker-password=$docker_password --docker-email=$docker_email

kubectl patch serviceaccount calico-node -n calico-system -p '{"imagePullSecrets":[{"name": "dockerhub-secret"}]}'

kubectl patch serviceaccount goldmane -n calico-system -p '{"imagePullSecrets":[{"name": "dockerhub-secret"}]}'

kubectl patch serviceaccount whisker -n calico-system -p '{"imagePullSecrets":[{"name": "dockerhub-secret"}]}'

kubectl patch serviceaccount csi-node-driver -n calico-system -p '{"imagePullSecrets":[{"name": "dockerhub-secret"}]}'

kubectl create secret docker-registry dockerhub-secret --namespace=calico-apiserver --docker-server=https://index.docker.io/v1/ --docker-username=$docker_username --docker-password=$docker_password --docker-email=$docker_email

kubectl patch serviceaccount calico-apiserver  -n calico-apiserver -p '{"imagePullSecrets":[{"name": "dockerhub-secret"}]}'

# kubectl create namespace tigera-operator
# helm install calico projectcalico/tigera-operator --version v3.30.3 --namespace tigera-operator



# 16. Check the status of the cluster
# kubectl get pods -n calico-system

# 17. Remove the taints on the control plane so that you can schedule pods on it
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# 18. Check the nodes
kubectl get nodes -o wide

# 19 setup runtime-endpoint for crictl to supress warnings (optional)
sudo crictl config runtime-endpoint unix:///run/containerd/containerd.sock

sleep 30

echo "Sleeping for 30 seconds"

kubectl get nodes -o wide
