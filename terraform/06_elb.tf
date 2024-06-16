# ------------------------------------------------------------#
#  ALB
# ------------------------------------------------------------#
resource "aws_lb" "alb" {
  name               = "${var.tag_name}-alb"
  load_balancer_type = "application"
  internal           = false
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_sub_a.id, aws_subnet.private_sub_c.id]
  tags = {
    Name = "${var.tag_name}-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.tag_name}-alb-tg-a"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  protocol    = "HTTP"
  port        = 80
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
  tags = {
    Name = "${var.tag_name}-alb-tg"
  }
}


resource "aws_lb_target_group_attachment" "alb_target_attach_ec2_a" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.ec2_a.id
}

resource "aws_lb_target_group_attachment" "alb_target_attach_ec2_c" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.ec2_c.id
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }
  port     = "80"
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
