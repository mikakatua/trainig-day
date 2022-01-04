provider "aws" {
  region = var.aws_region
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id          = module.vpc.vpc_id
  subnets         = [module.vpc.private_subnets[0], module.vpc.public_subnets[1]]
  fargate_subnets = [module.vpc.private_subnets[2]]

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  node_groups = {
    example = {
      desired_capacity = 1

      instance_types = ["t3.large"]
      k8s_labels = {
        Example    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "example"
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }
  manage_aws_auth = false

  tags = var.common_tags
}


################################################################################
# Kubernetes provider configuration
################################################################################

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

################################################################################
# Supporting Resources
################################################################################

data "aws_availability_zones" "available" {
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = var.cluster_name
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = var.common_tags
}

