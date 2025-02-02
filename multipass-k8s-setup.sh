brew install multipass

multipass launch --name kubemaster --cpus 2 --memory 2GB --disk 20GB

multipass launch --name kubeworker01 --cpus 2 --mem 2GB --disk 20GB
multipass launch --name kubeworker02 --cpus 2 --mem 2GB --disk 20GB

