resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = aws_subnet.subnet[*].id
#  availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity     = "2"
  launch_configuration = "${aws_launch_configuration.lc.name}"
  max_size             = "2"
  min_size             = "2"
  default_cooldown     = "0"
  name                 = "ASG for ${var.project} project"
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.web.name]

  depends_on = [aws_db_instance.default, aws_efs_mount_target.efs-mt]

  dynamic "tag" {
    for_each = var.global_tags
    content {
      key    =  tag.key
      value   =  tag.value
      propagate_at_launch =  true
    }
  }
  tag {
    key                 = "Name"
    value               = "for ${var.project} project"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "lc" {
#  name                        = "${var.s_project}_LC"
  image_id                    = "ami-04ad2567c9e3d7893"
  instance_type               = "t2.micro"
  name_prefix                 = "${var.s_project}_LC-"
  security_groups             = [aws_security_group.ec2_sg.id]
  key_name                    = "key-n.virginia"
  iam_instance_profile        = "${aws_iam_instance_profile.ins_profile.name}"

  user_data     = templatefile("user_data.tpl", {
    db_name     = var.db.name,
    db_user     = var.db.user,
    db_host     = aws_db_instance.default.endpoint
    efs_id      = aws_efs_file_system.default.id
    elb_dns     = aws_elb.web.dns_name
  })
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "ec2_sg" {
  name        = "SSH-HTTP-HTTPS"
  description = "SSH-HTTP-HTTPS"
  vpc_id = aws_vpc.main.id
  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge( var.global_tags,
    {
      Name = "EC2 SG for ${var.project} project"
    },
  )

}
