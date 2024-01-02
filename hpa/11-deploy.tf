resource "kubectl_manifest" "deploy" {
    yaml_body = <<-YAML
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: express
          namespace: default
        spec:
          selector:
            matchLabels:
              app: express
          template:
            metadata:
              labels:
                app: express
            spec:
              containers:
              - name: express
                imagePullPolicy: Always
                image: aputrabay/express:v1.0.0
                ports:
                - containerPort: 8080
                resources:
                limits:
                  cpu: 500m
                  memory: 256Mi
                requests:
                  cpu: 200m
                  memory: 128Mi

    YAML
    depends_on = [
      aws_eks_node_group.private-nodes
    ]
}