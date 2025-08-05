resource "aws_launch_template" "web" {
  name_prefix   = "web-launch-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd amazon-cloudwatch-agent
systemctl start httpd
systemctl enable httpd
echo "<h1>Web Server from Auto Scaling</h1>" > /var/www/html/index.html

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "web-asg"
    },
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOT

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
EOF
  )

  vpc_security_group_ids = [var.web_sg_id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name        = "web-launch-${var.environment}"
      Environment = var.environment
    })
  }
}

resource "aws_autoscaling_group" "web" {
  name_prefix         = "web-asg-${var.environment}-"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-asg-${var.environment}"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = merge(var.common_tags, { Environment = var.environment })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }

  ### ✅ Fix: Wait until Launch Template is ready
  depends_on = [aws_launch_template.web]
}

resource "aws_lb" "web_alb" {
  name               = "web-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_sg_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.common_tags, {
    Name        = "web-alb-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Name        = "web-tg-${var.environment}"
    Environment = var.environment
  })
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_autoscaling_attachment" "web_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn    = aws_lb_target_group.web_tg.arn
}