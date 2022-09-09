resource "aws_appautoscaling_target" "scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/project-${var.env}-cluster/project-${var.env}-inbound-ecs-service"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = "1"
  max_capacity       = "2"
  
  depends_on = [
    aws_ecs_service.service, aws_ecs_task_definition.task
  ]
}

resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "project-${var.env}-inbound-scale-up-policy"
  depends_on         = [aws_appautoscaling_target.scale_target]
  service_namespace  = "ecs"
  resource_id        = "service/project-${var.env}-cluster/project-${var.env}-inbound-ecs-service"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_down_policy" {
  name               = "project-${var.env}-inbound-scale-down-policy"
  depends_on         = [aws_appautoscaling_target.scale_target]
  service_namespace  = "ecs"
  resource_id        = "service/project-${var.env}-cluster/project-${var.env}-inbound-ecs-service"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "project-${var.env}-inbound-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Maximum"
  threshold           = "75"
  dimensions = {
    ClusterName = "project-${var.env}-cluster"
    ServiceName = "project-${var.env}-inbound-ecs-service"
  }
  alarm_actions = [aws_appautoscaling_policy.scale_up_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "project-${var.env}-inbound-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "15"
  dimensions = {
    ClusterName = "project-${var.env}-cluster"
    ServiceName = "project-${var.env}-inbound-ecs-service"
  }
  alarm_actions = [aws_appautoscaling_policy.scale_down_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "messages_not_visible" {
  alarm_name          = "project-${var.env}-inbound-messages_not_visible_q2"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesNotVisible"
  namespace           = "AWS/SQS"
  period              = "120"
  statistic           = "Sum"
  threshold           = "1"
  datapoints_to_alarm = 2
  treat_missing_data  = "missing"
  dimensions = {
    QueueName = "project-${var.env}-inbound-sqs-q2.fifo"
  }
  alarm_actions = [aws_appautoscaling_policy.scale_down_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "messages_not_visible1" {
  alarm_name          = "project-${var.env}-inbound-messages_not_visible_q1"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesNotVisible"
  namespace           = "AWS/SQS"
  period              = "120"
  statistic           = "Sum"
  threshold           = "1"
  datapoints_to_alarm = 2
  treat_missing_data  = "missing"
  dimensions = {
    QueueName = "project-${var.env}-inbound-sqs-q1.fifo"
  }
  alarm_actions = [aws_appautoscaling_policy.scale_down_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "messages_visible" {
  alarm_name          = "project-${var.env}-inbound-messages_visible_q2"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "120"
  statistic           = "Sum"
  threshold           = "100"
  datapoints_to_alarm = 2
  treat_missing_data  = "missing"
  dimensions = {
    QueueName = "project-${var.env}-inbound-sqs-q2.fifo"
  }
  alarm_actions = [aws_appautoscaling_policy.scale_up_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "messages_visible1" {
  alarm_name          = "project-${var.env}-inbound-messages_visible_q1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "120"
  statistic           = "Sum"
  threshold           = "100"
  datapoints_to_alarm = 2
  treat_missing_data  = "missing"
  dimensions = {
    QueueName = "project-${var.env}-inbound-sqs-q1.fifo"
  }
  alarm_actions = [aws_appautoscaling_policy.scale_up_policy.arn]
}

# module "metric_alarms" {
#   source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
#   version = "~> 3.0"

#   alarm_name          = "project-${var.env}-inbound-messages_not_visible"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 2
#   threshold           = 1
#   period              = 120
#   datapoints_to_alarm = 2
#   treat_missing_data  = "missing"

#   namespace   = "AWS/SQS"
#   metric_name = "ApproximateNumberOfMessagesNotVisible"
#   statistic   = "Sum"

#   dimensions = {
#     "q1" = {
#       QueueName = "project-${var.env}-inbound-sqs-q1.fifo"
#     },
#     "q2" = {
#       QueueName = "project-${var.env}-inbound-sqs-q2.fifo"
#     },
#   }

#   alarm_actions = [aws_appautoscaling_policy.scale_down_policy.arn]
# }