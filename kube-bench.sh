#Install kube-bench

git clone https://github.com/aquasecurity/kube-bench
cd kube-bench

make build
sudo cp bin/kube-bench /usr/local/bin/

sudo chown root:root kube-bench
sudo chmod +x kube-bench
sudo cp kube-bench /usr/local/bin/
