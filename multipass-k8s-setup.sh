brew install multipass



# multipass transfer <vm-name>:/path/to/file/on/vm /local/path/to/save/file. 


# multipass launch --name control-plane --cpus 6 --memory 6GB --disk 100GB
# multipass launch --name kube-worker01 --cpus 6 --memory 4GB --disk 100GB
# multipass launch --name kube-worker02 --cpus 6 --memory 4GB --disk 100GB
# multipass launch --name kube-worker03 --cpus 6 --memory 4GB --disk 100GB
# multipass launch --name kube-worker04 --cpus 6 --memory 4GB --disk 100GB
# multipass launch --name kube-worker05 --cpus 6 --memory 4GB --disk 100GB
# multipass launch --name kube-worker06 --cpus 6 --memory 4GB --disk 100GB