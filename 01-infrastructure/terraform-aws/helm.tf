resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.16.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter_irsa.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }
}

resource "helm_release" "kube_prometheus_stack" {
  depends_on = [
    module.eks
  ]

  namespace        = "monitoring"
  create_namespace = true

  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "43.1.0"
}

resource "helm_release" "kubernetes_dashboard" {
  depends_on = [
    module.eks
  ]

  namespace        = "kubernetes-dashboard"
  create_namespace = true

  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  version    = "6.0.0"

  set {
    name  = "metricsScraper.enabled"
    value = "true"
  }

  set {
    name  = "metrics-server.enabled"
    value = "true"
  }

  set {
    name  = "metrics-server.args"
    value = "{--kubelet-insecure-tls}"
  }
}