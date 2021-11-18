resource "aws_efs_file_system" "default" {
   creation_token = "EFS for ${var.project} project"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "false"
   tags = merge( var.global_tags,
     {
       Name = "EFS for ${var.project} project"
     },
   )
}

resource "aws_efs_mount_target" "efs-mt" {
   count = length(aws_subnet.subnet)
   file_system_id  = "${aws_efs_file_system.default.id}"
   subnet_id = "${aws_subnet.subnet[count.index].id}"
   security_groups = ["${aws_security_group.efs_sg.id}"]
 }

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.default.id
  backup_policy {
    status = "DISABLED"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "Security group for EFS"
  description = "Security group for EFS"
  vpc_id = aws_vpc.main.id
  ingress {
      from_port   = 2049
      to_port     = 2049
      protocol    = "TCP"
      cidr_blocks = values(var.subnets)[*]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = values(var.subnets)[*]
  }


  tags = merge( var.global_tags,
    {
      Name = "EFS SG for ${var.project} project"
    },
  )

}
