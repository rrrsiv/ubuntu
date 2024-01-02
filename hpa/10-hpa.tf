resource "kubectl_manifest" "hpa" {
    yaml_body = <<-YAML
        apiVersion: autoscaling/v2beta2
        kind: HorizontalPodAutoscaler
        metadata:
          name: express
          namespace: default
        spec:
          scaleTargetRef:
            apiVersion: apps/v1
            kind: Deployment
            name: express
          minReplicas: 1
          maxReplicas: 10
          behavior:
            scaleUp:
              policies:
              - type: Pods
                value: 1
                periodSeconds: 60
            scaleDown:
              policies:
              - type: Percent
                value: 10
                periodSeconds: 60
          metrics:
          - type: Resource
            resource:
              name: cpu
              target:
                type: Utilization
                averageUtilization: 80
          - type: Resource
            resource:
              name: memory
              target:
                type: Utilization
                averageUtilization: 70

    YAML
    depends_on = [
      aws_eks_node_group.private-nodes
    ]
}
