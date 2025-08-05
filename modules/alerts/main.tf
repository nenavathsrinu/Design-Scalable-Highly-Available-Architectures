resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = var.web_asg_name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = var.web_asg_name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale out when CPU > 70%"
  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "low-cpu-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale in when CPU < 30%"
  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

resource "aws_cloudwatch_metric_alarm" "ram_high" {
  alarm_name          = "high-ram-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 120
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Scale out when RAM > 75%"
  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_sns_topic" "rds_alerts" {
  name = "rds-failover-alerts"
  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.rds_alerts.arn
  protocol  = "email"
  endpoint  = "nenavath2013@gmail.com"
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn = aws_sns_topic.rds_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "events.amazonaws.com" },
        Action = "SNS:Publish",
        Resource = aws_sns_topic.rds_alerts.arn
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "rds_failover" {
  name        = "rds-failover-event"
  description = "Detect RDS failover events"
  event_pattern = jsonencode({
    source: ["aws.rds"],
    "detail-type": ["RDS DB Instance Event"],
    detail: {
      EventCategories: ["failover"],
      SourceIdentifier: [var.rds_identifier],
      SourceType: ["DB_INSTANCE"]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.rds_failover.name
  target_id = "send-rds-alert"
  arn       = aws_sns_topic.rds_alerts.arn
}
