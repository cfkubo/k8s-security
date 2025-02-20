# Install GO
sudo snap install go --classic

#Install kube-bench

git clone https://github.com/aquasecurity/kube-bench
cd kube-bench

make build
sudo cp bin/kube-bench /usr/local/bin/

sudo chown root:root kube-bench
sudo chmod +x kube-bench
sudo cp kube-bench /usr/local/bin/

# kube-linter install

git clone https://github.com/stackrox/kube-linter
cd kube-linter
make build
.gobin/kube-linter version
sudo chown root:root kube-linter
sudo cp kube-linter /usr/loca/bin/

# kubesec install

go install github.com/controlplaneio/kubesec/v2@latest

# Trivy Installation

sudo curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.18.3
