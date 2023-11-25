# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "DemoEventBridge" {
  ami           = "ami-0a5f04cdf7758e9f0"
  instance_type = "t2.micro"
  tags =  {
    name = var.DemoName
  }
}

resource "aws_sns_topic" "DemoEventBridge" {
  name = var.DemoName
}

resource "aws_sns_topic_subscription" "DemoEventBridge" {
  topic_arn = aws_sns_topic.DemoEventBridge.arn
  endpoint  = var.SubscriptionEmail
  protocol  = "email"
}

resource "aws_cloudwatch_event_bus" "DemoEventBridge" {
  name = var.DemoName
}

resource "aws_cloudwatch_event_target" "sns" {
 rule = aws_cloudwatch_event_rule.DemoEventBridge.name
 target_id = "SendToSns"
 arn = aws_sns_topic.DemoEventBridge.arn
 event_bus_name=var.DemoName
}

resource "aws_cloudwatch_event_rule" "DemoEventBridge" {
  depends_on = [ aws_cloudwatch_event_bus.DemoEventBridge ]
  name           = var.DemoName
  event_bus_name = var.DemoName
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail" : {
      "state" : ["stopped", "terminated"]
    }
  })
}