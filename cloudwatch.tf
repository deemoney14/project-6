#cloudwatch scale up
resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "scale-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70


  dimensions = {
    aws_autoscaling_groupName = aws_autoscaling_group.ngx_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale-up-asg.arn]
}
# asg scale up
resource "aws_autoscaling_policy" "scale-up-asg" {
  name                   = "scale-up-asg"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ngx_asg.name

}

#cloudwatch scale down
resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "scale-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30


  dimensions = {
    aws_autoscaling_groupName = aws_autoscaling_group.ngx_asg.id
  }

  alarm_actions = [aws_autoscaling_policy.scale-down-asg.arn]
}

# asg scale up
resource "aws_autoscaling_policy" "scale-down-asg" {
  name                   = "scale-down-asg"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ngx_asg.name
}