sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://gvisor.dev/archive.key | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64,arm64] https://storage.googleapis.com/gvisor/releases release main"

sudo apt-get update
sudo apt-get install -y runsc

sudo runsc install
sudo systemctl restart docker

## docker run --runtime=runsc --rm hello-world
## docker run --runtime=runsc -it hello-world dmesg
