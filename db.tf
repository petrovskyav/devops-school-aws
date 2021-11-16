resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"
  keepers = { 
    keeper1 = var.db.name
  }
}

resource "aws_ssm_parameter" "rds_password" {
  name        = var.ssm_mysql_root_location
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value = random_string.rds_password.result
}

resource "aws_db_instance" "default" {
  identifier = "wordpressdb"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.23"
  instance_class       = "db.t2.micro"
  name                 = var.db.name
  username             = var.db.user
  password             = aws_ssm_parameter.rds_password.value
  skip_final_snapshot  = true
  apply_immediately = true
  vpc_security_group_ids             = [aws_security_group.mysql.id]
}

resource "aws_security_group" "mysql" {
  name        = "MySQL"
  description = "MySQL"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "MySQL"
    Terraform   = "true"
  }

}
