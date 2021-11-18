variable "region" {
  default = "us-east-1"
}

variable "project" {
  default = "WordPress HA"
}

variable "s_project" {
  default = "WP"
}

variable "application" {
  default = "WordPress"
}

variable "owner" {
  default = "Aleksandr_Petrovskii1"
}


variable "vpc_cidr" {
  description = "VPC cidr"
  default = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subnets cidr"
  type        = map(any)
  default = {
    a = "10.0.0.0/24"
    b = "10.0.1.0/24"
  }
}

variable "db" {
  description = "Variables for the DataBase connection"
  type        = map(any)
  default = {
    name   = "wordpress"
    user = "wordpressuser"
  }
}

variable "ssm_mysql_root_location" {
  type = string
  default = "/wp/mysql_root_password_location"

}



variable "global_tags" {
  description = "Map of specific tags that will be added to the defaults (e.g. Name) for all AWS resources."
  type = map(any)
  default = {
    Application = "WordPress"
    Terraform = "true"
    Project = "WordPress HA"
    owner = "Aleksandr_Petrovskii1"
  }
}
