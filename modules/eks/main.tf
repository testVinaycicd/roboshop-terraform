resource "aws_eks_cluster" "main" {
  name = var.env

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.cluster-role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.subnets
  }



}

resource "aws_eks_node_group" "main" {
  for_each = var.node_groups
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = var.subnets
  instance_types = each.value["instance_type"]

  scaling_config {
    desired_size = each.value["min_nodes"]
    max_size     = each.value["max_nodes"]
    min_size     = each.value["min_nodes"]
  }

  # This ensures Terraform waits for the cluster to be ACTIVE
  depends_on = [aws_eks_cluster.main]

  # Increase timeout to give AWS more breathing room
  # wait_for_capacity_timeout = "30m"


}



resource "aws_eks_access_entry" "main" {
  for_each = var.access
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value["role"]
  kubernetes_groups = each.value["kubernetes_groups"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "main" {
  for_each = var.access
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value["role"]

  access_scope {
    type       = "cluster"
    namespaces = []
  }
}

resource "aws_eks_pod_identity_association" "external-dns" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "default"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external-dns.arn
}

# for cluster namespaces doesn't matter
