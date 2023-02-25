resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.23.1"

  create_namespace = true
  namespace        = "argocd"

  set {
    name = "configs.secret.argocdServerAdminPassword"
    value = "$2a$04$t.UPqh3oZQTueIlCqcPH0eyFJl5A/agoOHP4Mibk9xUkMS0/4t2EW"
  }

  set {
    name = "configs.repositories.github-repo.url"
    value = "https://github.com/rickardosmith/gitops_with_argocd.git"
  }

  set {
    name = "configs.repositories.github-repo.name"
    value = "github-rickardosmith"
  }

  set {
    name = "configs.repositories.github-repo.type"
    value = "git"
  }
}