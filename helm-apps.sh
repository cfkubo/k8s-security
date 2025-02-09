# open-webui
helm repo add open-webui https://helm.openwebui.com/
helm repo update

kubectl create namespace open-webui
helm upgrade --install open-webui open-webui/open-webui --namespace open-webui

# Cert-Manager
helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  --set crds.enabled=true

# opa/gatekeeper
helm repo add opa https://open-policy-agent.github.io/gatekeeper/charts
helm repo update
helm install opa opa/gatekeeper --namespace gatekeeper-system --create-namespace

## openebs for local storage dynamic provisioning 
helm repo add openebs https://openebs.github.io/openebs
helm repo update

helm install openebs --namespace openebs openebs/openebs --create-namespace

# make hostpath the default sc
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

##cloudnative-postgres
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg

## Prometheus Grafana Loki
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

## ArgoCD
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd --namespace argocd --create-namespace

# Metrics Server  ## --kubelet-insecure-tls  edit metris-server delploy to add `--kubelet-insecure-tls`  this flag if you are using self-signed certs 
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install metrics-server metrics-server/metrics-server --namespace kube-system --create-namespace


## Kubeshark - kube api traffic analyzer/monitoring
helm repo add kubeshark https://helm.kubeshark.co
helm install kubeshark kubeshark/kubeshark --namespace kubeshark --create-namespace

## Kubenetes Dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

# ## KubeDB
# helm repo add appscode https://charts.appscode.com/stable/
# helm install kubedb-operator appscode/kubedb --namespace kubedb --create-namespace

# ## KubeDB Postgres
# helm install postgres kubedb/postgres --namespace kubedb --create-namespace

# ## KubeDB Elasticsearch
# helm install elasticsearch kubedb/elasticsearch --namespace kubedb --create-namespace

# ## KubeDB Minio
# helm install minio kubedb/minio --namespace kubedb --create-namespace

# ## KubeDB Redis
# helm install redis kubedb/redis --namespace kubedb --create-namespace

# ## KubeDB MongoDB
# helm install mongodb kubedb/mongodb --namespace kubedb --create-namespace

# ## KubeDB MySQL 
# helm install mysql kubedb/mysql --namespace kubedb --create-namespace

# ## KubeDB MariaDB
# helm install mariadb kubedb/mariadb --namespace kubedb --create-namespace

# ## KubeDB Memcached
# helm install memcached kubedb/memcached --namespace kubedb --create-namespace

# ## KubeDB ProxySQL
# helm install proxysql kubedb/proxysql --namespace kubedb --create-namespace