echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo kubeadm upgrade plan
sudo apt update
sudo apt-cache madison kubeadm
 # replace x in 1.30.x-* with the latest patch version
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm='1.30.0-1.1' && sudo apt-mark hold kubeadm
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.30.0
sudo apt-mark unhold kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubelet='1.30.0-1.1' kubectl='1.30.0-1.1' && sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
kubectl get no
