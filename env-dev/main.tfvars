db_instances = {

  mongo = {
    ami_id = "ami-09c813fb71547fc4f"
    instance_type = "t3.small"
    root_volume_size = 20

  },

  redis = {
    ami_id = "ami-09c813fb71547fc4f"
    instance_type = "t3.small"
    root_volume_size = 20

  },



  #
  mysql = {
    ami_id = "ami-09c813fb71547fc4f"
    instance_type = "t3.small"
    root_volume_size = 20
  },

  rabbitmq = {
    ami_id = "ami-09c813fb71547fc4f"
    root_volume_size = 20
    instance_type = "t3.small"
  },




}

zone_id = "Z09180393TY9K7UQDKE5E"

vpc_security_group_ids = ["sg-0171a68ab5d431564"]

env="dev"

eks = {
  main = {
    subnets = ["subnet-0c8c156354b299b12","subnet-068d93372de56df27"]
    eks_version = 1.32
    node_groups = {
        main = {
          min_nodes = 3
          max_nodes = 10
          instance_type = ["t3.medium","t3.large"]
        }
    }
    addons = {
      eks-pod-identity-agent ={}
    }

    access = {
      workstation = {
        role                    = "arn:aws:iam::633788536644:role/workstation-role"
        kubernetes_groups       = ["system:masters"]
        policy_arn              = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope_type       = "cluster"
        access_scope_namespaces = []
      }
    }

  }
}

# terraform plan -var-file=env-prod/main.tfvars
