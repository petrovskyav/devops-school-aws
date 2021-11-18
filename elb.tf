resource "aws_elb" "web" {
  name               = "${var.s_project}-ELB"
#  availability_zones = [for k,v in var.subnets : "${var.region}${k}"]
  subnets = aws_subnet.subnet[*].id

  security_groups    = [aws_security_group.elb_sg.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  tags = merge( var.global_tags,
    {
      Name = "ELB for ${var.project} project"
    },
  )
}

resource "aws_security_group" "elb_sg" {
  name        = "Security group for ELB"
  description = "Security group for ELB"
  vpc_id = aws_vpc.main.id
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge( var.global_tags,
    {
      Name = "ELB SG for ${var.project} project"
    },
  )

}
