# kube-linter install
sudo apt install make
sudo snap install go --classic

git clone https://github.com/stackrox/kube-linter
cd kube-linter
make build
.gobin/kube-linter version
