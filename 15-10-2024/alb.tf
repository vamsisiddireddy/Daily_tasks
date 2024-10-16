# Create the Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"] 

  enable_deletion_protection = false
}

# Create a target group for your instances
resource "aws_lb_target_group" "app_tg" {
  name     = "my-app-tg"
  port     = 8080
  protocol = "HTTP"  # Change to "HTTPS" if your application uses SSL internally
  vpc_id   = ""  

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

# Create a listener for the load balancer
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "#{host}"
      path        = "/"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"  # Specify the desired SSL policy
  certificate_arn   = "arn:aws:acm:us-west-2:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Replace with your SSL certificate ARN

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Optionally, add EC2 instances to the target group
resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = "i-0abcd1234efgh5678"  # Replace with your instance ID
  port             = 80
}
