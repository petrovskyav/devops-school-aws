resource "aws_lb" "web" {
  name               = "${var.s_project}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.subnet.*.id
  tags = merge(var.global_tags,
    {
      Name = "ELB for ${var.project} project"
    },
  )
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.lb_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "${var.s_project}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200-399"
  }
  tags = merge(var.global_tags,
    {
      Name = "TG for ${var.project} project"
    },
  )
}

resource "aws_security_group" "lb_sg" {
  name        = "Security group for ELB"
  description = "Security group for ELB"
  vpc_id      = aws_vpc.main.id
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
  tags = merge(var.global_tags,
    {
      Name = "ELB SG for ${var.project} project"
    },
  )
}
