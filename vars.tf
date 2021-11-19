variable "ssh_key_name" {
  description = "The name of existing ssh key for EC2 instances"
  default     = "key-london"
}

variable "region" {
  description = "The AWS region for this project"
  default     = "eu-west-2"
}

variable "project" {
  description = "The name of the project"
  default     = "WordPress HA"
}

variable "s_project" {
  description = "The short name of the project"
  default     = "WP"
}

variable "application" {
  description = "The name of application in the project"
  default     = "WordPress"
}

variable "owner" {
  description = "The name of owner of creating resources"
  default     = "Aleksandr_Petrovskii1"
}

variable "vpc_cidr" {
  description = "VPC cidr block"
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "AZ letters and subnets blocks for subnets"
  type        = map(any)
  default = {
    a = "10.0.0.0/24"
    b = "10.0.1.0/24"
  }
}

variable "db" {
  description = "Variables for the DataBase connection."
  type        = map(any)
  default = {
    name = "wordpress"
    user = "wordpressuser"
  }
}

variable "global_tags" {
  description = "Global tags. Will be on the most of resources"
  type        = map(any)
  default = {
    Application = "WordPress"
    Terraform   = "true"
    Project     = "WordPress HA"
    owner       = "Aleksandr_Petrovskii1"
  }
}
