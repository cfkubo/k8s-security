#Install kube-bench
sudo snap install go --classic
git clone https://github.com/aquasecurity/kube-bench
cd kube-bench

make build
sudo cp kube-bench /usr/local/bin/

sudo chown root:root kube-bench
sudo chmod +x kube-bench
sudo cp kube-bench /usr/local/bin/
