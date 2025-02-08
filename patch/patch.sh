 kubectl patch storageclass openebs-single-replica -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
