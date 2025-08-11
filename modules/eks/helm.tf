resource "aws_eks_addon" "addons" {
  for_each = var.addons
  cluster_name = aws_eks_cluster.main.name
  addon_name   = each.key
}

resource "null_resource" "kubeconfig" {
  depends_on = [aws_eks_node_group.main]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.env} "
  }
}

resource "null_resource" "metrics-server" {
  depends_on = [null_resource.kubeconfig]

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
  }
}



resource "helm_release" "kube-prometheus-stack" {
  depends_on = [null_resource.kubeconfig,helm_release.cert-manager]
  name       = "kube-prom-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    file("s(path.module)/helm-config/prom-stack-${var.env}.yml")
  ]

}

resource "helm_release" "ingress" {
  depends_on = [null_resource.kubeconfig]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [
  file("${ path.module }/helm-config/ingress.yml")
  ]
}


resource "helm_release" "cert-manager" {
  depends_on       = [null_resource.kubeconfig]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set_sensitive = [ {
    name  = "crds.enabled"
    value = "true"
  }]
}

resource "null_resource" "cert-manager-cluster-issuer" {
  depends_on = [null_resource.kubeconfig, helm_release.cert-manager]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/helm-config/clusterIssuer.yml"
  }
}

resource "helm_release" "external-dns" {
  depends_on = [null_resource.kubeconfig]
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
}

resource "helm_release" "argocd" {
  depends_on = [ helm_release.external-dns,helm_release.ingress,helm_release.cert-manager]
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    namespace = "argocd"
    create_namespace = true
    wait = false

  set= [ {
    name = "global.domain"
    value="argocd-$(var.env).mikeydevops1.online"
  }]


  values = [
    file("${path.module}/helm-config/argocd.yml")
    ]
}


