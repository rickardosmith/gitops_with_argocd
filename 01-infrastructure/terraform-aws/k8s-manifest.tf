resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot"]
    limits:
      resources:
        cpu: 1000
    provider:
      subnetSelector:
        Name: "*private*"
      securityGroupSelector:
        karpenter.sh/discovery/${module.eks.cluster_id}: ${module.eks.cluster_id}
      tags:
        karpenter.sh/discovery/${module.eks.cluster_id}: ${module.eks.cluster_id}
    ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

data "kubectl_file_documents" "eks_admin_service_account" {
  content = <<-YAML
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: eks-readonly
    namespace: kube-system
  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: eks-readonly
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: view
  subjects:
  - kind: ServiceAccount
    name: eks-readonly
    namespace: kube-system
  YAML
}

resource "kubectl_manifest" "eks_admin_service_account" {
  count     = length(data.kubectl_file_documents.eks_admin_service_account.documents)
  yaml_body = element(data.kubectl_file_documents.eks_admin_service_account.documents, count.index)

  depends_on = [
    helm_release.kubernetes_dashboard
  ]
}