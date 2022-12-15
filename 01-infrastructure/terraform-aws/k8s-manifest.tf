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