locals {
  owner = "Aleksandr_Petrovskii1"
  project = "EPAM AWS school"
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
