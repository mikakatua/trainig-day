variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable cluster_name {
  description = "EKS Cluster name"
  type        = string
  default     = "fargate-test"
}

variable cluster_version {
  description = "EKS Cluster version"
  type        = string
  default = "1.20"
}

variable common_tags {
  description = "Map of default tags" 
  type = map
  default = {
    env = "test"
    project = "trainig-day"
  }
}

variable rds_name {
  description = "RDS Mysql name"
  type        = string
  default     = "mysql-test"
}

