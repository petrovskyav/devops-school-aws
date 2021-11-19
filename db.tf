resource "random_string" "rds_password" {
  length  = 12
  special = false
  #  override_special = "!#&"
  keepers = {
    keeper1 = var.db.name
  }
}

resource "aws_ssm_parameter" "rds_password" {
  name        = "/${var.s_project}/mysql-password"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
  tags = merge(var.global_tags,
    {
      Name = "MySQL root password for ${var.project} project"
    },
  )
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = aws_subnet.subnet[*].id
  tags = merge(var.global_tags,
    {
      Name = "DB subnet group for ${var.project} project"
    },
  )
}

resource "aws_db_instance" "default" {
  #  identifier = "wordpressdb"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.23"
  instance_class         = "db.t2.micro"
  name                   = var.db.name
  username               = var.db.user
  password               = aws_ssm_parameter.rds_password.value
  skip_final_snapshot    = true
  apply_immediately      = true
  vpc_security_group_ids = [aws_security_group.mysql.id]
  tags = merge(var.global_tags,
    {
      Name = "DB for ${var.project} project"
    },
  )
}

resource "aws_security_group" "mysql" {
  name        = "MySQL"
  description = "MySQL"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = values(var.subnets)[*]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = values(var.subnets)[*]
  }
  tags = merge(var.global_tags,
    {
      Name = "DB SG for ${var.project} project"
    },
  )
}
