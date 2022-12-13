# GitOps with ArgoCD

# Deploy
1.  Infrastructure (Optional)
    1.  AWS
        1.  `cd 01-infrastructure/terraform-aws`
        2.  `terraform init`
        3.  `terraform apply`
2.   GitOps
     1. Set your Kubernetes Context (this portion assume Kubernetes Cluster hosted on AWS)
        1. `aws eks update-kubeconfig --region us-east-1 --name gitops --alias gitops`
     2. Create ArgoCD Kubernetes Namespace
        1. `kubectl create namespace argocd`
     3. Install ArgoCD via Helm Chart in K8s Namespace `argocd`
        1. `cd 02-gitops/argocd/argocd-install/argo-cd`
        2. `helm install argocd . -f ../argocd-install-values-override.yaml -n argocd`
     4. Install ArgoCD Applications via Helm Chart in K8s Namespace `argocd`
        1. `cd ../argocd-apps`
        2. `helm install argocd-apps . -f ../argocd-apps-values-override.yaml -n argocd`

