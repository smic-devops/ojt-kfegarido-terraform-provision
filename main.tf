data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "alb_sg" {
  name        = "ojt-kfegarido-alb-sg"
  description = "ALB SG"
  vpc_id      = var.vpc_id
}

# Internet to ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "alb_https_in" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb_sg.id
  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_lb" "test" {
  name               = "ojt-kfegarido-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.public_subnet1, var.public_subnet2]
}

# Target group
resource "aws_lb_target_group" "app_tg" {
  name     = "ojt-kfegarido-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

########### EC2 Instance & SG

resource "aws_security_group" "ec2_sg" {
  name        = "ojt-kfegarido-ec2-sg"
  description = "EC2 app SG"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.ec2_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_egress_all" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami                    = var.ami_type
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet1
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "itss-ojt-kfegarido-ec2"
  }

}

# Register EC2 into TG
resource "aws_lb_target_group_attachment" "app_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}