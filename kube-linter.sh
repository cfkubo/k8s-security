# kube-linter install
sudo apt install make
sudo snap install go --classic
go install golang.stackrox.io/kube-linter/cmd/kube-linter@latest

# git clone https://github.com/stackrox/kube-linter
# cd kube-linter
# make build
# .gobin/kube-linter version
