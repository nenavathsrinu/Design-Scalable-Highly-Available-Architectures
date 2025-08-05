data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {  
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_lb" "app_nlb" {
  name               = "app-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
  enable_cross_zone_load_balancing = true

  tags = merge({ Name = "app-nlb" }, var.common_tags)
}

resource "aws_lb_target_group" "app_tg" {
  name        = "app-nlb-tg"
  port        = 3000
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = merge({ Name = "app-nlb-tg" }, var.common_tags)
}

resource "aws_instance" "app_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name  # This must be valid in selected region
  user_data = <<-EOF
              #!/bin/bash
              sudo su -
              yum update -y
              yum install -y docker git
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              git clone https://github.com/nenavathsrinu/sample-node-app.git /home/ec2-user/app
              cd /home/ec2-user/app
              docker build -t app .

              docker run -d -p 3000:3000 \
                -e DB_HOST="${var.rds_endpoint}" \
                -e DB_PORT=3306 \
                -e DB_USER="${var.rds_username}" \
                -e DB_PASS="${var.rds_password}" \
                app
              EOF

  tags = merge({ Name = "app-ec2" }, var.common_tags)
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_ec2.id
  port             = 3000
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_nlb.arn
  port              = 3000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}