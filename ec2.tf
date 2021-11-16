resource "aws_autoscaling_group" "wordpress_asg" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity     = "1"
  launch_configuration = "${aws_launch_configuration.wordpress_lc.name}"
  max_size             = "1"
  min_size             = "1"
  default_cooldown     = "0"
  name                 = "WordPress_ASG"
  tags = [
    {
      key                 = "Name"
      value               = "WordPress"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = local.owner
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = local.project
      propagate_at_launch = true
    }
  ]
}


resource "aws_launch_configuration" "wordpress_lc" {
#  name                        = "WordPress_LC"
  image_id                    = "ami-04ad2567c9e3d7893"
  instance_type               = "t2.micro"
  name_prefix                 = "WordPress_LC-"
  security_groups             = [aws_security_group.allow_ssh_http_https.id]
  key_name                    = "key-n.virginia"
  iam_instance_profile        = "${aws_iam_instance_profile.wp_node.name}"

  user_data     = templatefile("user_data.tpl", {
    db_name     = var.db.name,
    db_user     = var.db.user,
    db_host     = aws_db_instance.default.endpoint
  })
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "allow_ssh_http_https" {
  name        = "SSH-HTTP-HTTPS"
  description = "SSH-HTTP-HTTPS"

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
  tags = {
    Name        = "SSH-HTTP-HTTPS"
    Terraform   = "true"
  }

}
