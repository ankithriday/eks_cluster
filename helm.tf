data "aws_eks_cluster" "this" {
  name = "ankit-test-cluster"
}

data "aws_eks_cluster_auth" "this" {
  name = "ankit-test-cluster"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", "ankit-test-cluster", "--region", "us-west-2"]
      command     = "aws"
    }
  }
}

resource "helm_release" "this" {

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "3.24.0"

#  create_namespace = var.k8s_create_namespace
  namespace        = "kube-system"
  name             = "ingress-nginx"

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }

#  depends_on = [var.mod_dependency]
}