helm repo install argo https://argoproj.github.io/argo-helm

helm install argocd argo/argo-cd


kubectl port-forward service/argocd-server -n default 8080:443

kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
