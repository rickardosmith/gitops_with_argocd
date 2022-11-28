resource "helm_release" "argocd" {
  name  = "argocd"
  chart = "${path.module}/../argocd/argocd-install/argo-cd"

  values = [
    "${file("${path.module}/../argocd/argocd-install/argo-cd/values.yaml")}",
    "${file("${path.module}/../argocd/argocd-install/argocd-install-values-override.yaml")}"
  ]

  namespace        = "argocd"
  create_namespace = true
}

resource "helm_release" "argocd_apps" {
  depends_on = [
    helm_release.argocd
  ]

  name  = "argocd-apps"
  chart = "${path.module}/../argocd/argocd-install/argocd-apps"

  values = [
    "${file("${path.module}/../argocd/argocd-install/argocd-apps/values.yaml")}",
    "${file("${path.module}/../argocd/argocd-install/argocd-apps-values-override.yaml")}"
  ]

  namespace        = "argocd"
  create_namespace = true
}