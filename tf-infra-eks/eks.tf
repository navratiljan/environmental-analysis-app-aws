locals {
  iam_role_policy_prefix      = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  cluster_iam_role_dns_suffix = null
  dns_suffix                  = coalesce(local.cluster_iam_role_dns_suffix, data.aws_partition.current.dns_suffix)
  iam_role_path               = null
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "eks-${local.infix}"
  cluster_version = "1.26"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  #iam_role_name = aws_iam_role.eks_node_group_instance_role.name

  vpc_id = module.vpc.vpc_id

  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    nodegroup-1 = {
      name                   = "managed-group-1"
      use_name_prefix        = true
      subnet_ids             = module.vpc.private_subnets
      vpc_security_group_ids = [module.vpc.default_security_group_id]
      min_size               = 1
      max_size               = 30
      desired_size           = 6


      create_iam_role          = true
      name                     = "${var.project_name}-${var.environment}-eks-nodegroup"
      iam_role_name            = var.eks_node_group_instance_role_name
      iam_role_use_name_prefix = false

      iam_role_additional_policies = {
        "CloudWatchAgentServerPolicy" = "${local.iam_role_policy_prefix}/CloudWatchAgentServerPolicy",
      "AmazonSSMManagedInstanceCore" = "${local.iam_role_policy_prefix}/AmazonSSMManagedInstanceCore" }

      instance_types = ["m5.2xlarge"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }

      ebs_optimized = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 200
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }
      enable_bootstrap_user_data = false

      tags = {
        "nodegroupName" : "${var.project_name}-${var.environment}-eks-nodegroup"
      }
    }
  }


  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::812222239604:role/AWSReservedSSO_AWSAdministratorAccess_2071fa091a7f10ed"
      username = "AWSAdministrators"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "777777777777",
    "888888888888",
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}