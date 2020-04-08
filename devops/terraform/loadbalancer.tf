variable "internal" {
  default = true
}

variable "deregistration_delay" {
  description = "The amount time for ELB to wait before changing the state of a deregistering target"
  default = "30"
}

variable "health_check" {
  description = "The path to the health check for the load balancer to know if the container(s) are ready"
}

variable "health_check_interval" {
  description = "How often to check the liveliness of the container"
  default = "30"
}

variable "health_check_timeout" {
  description = "How long to wait for the response on the health check path"
  default = "10"
}

variable "health_check_matcher" {
  description = "What HTTP response code to listen for"
  default = "200,404"
}

variable "lb_access_logs_expiration_days" {
  default = "3"
}

variable "lb_protocol" {
}

variable "lb_port" {
}

resource "aws_alb" "main" {
  name = "${var.app}-${var.environment}"
  internal = var.internal
  subnets = split(",", var.internal == true ? var.private_subnets : var.public_subnets)
  security_groups = [aws_security_group.lb.id]
  tags            = module.global.tags
  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.lb_access_logs.bucket
  }
}

resource "aws_alb_target_group" "main" {
  name                 = "${var.app}-${var.environment}"
  port                 = var.lb_port
  protocol             = var.lb_protocol
  vpc_id               = var.vpc
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
  tags = module.global.tags
}

data "aws_elb_service_account" "main" {
}

resource "aws_s3_bucket" "lb_access_logs" {
  bucket        = "${var.app}-${var.environment}-lb-access-logs"
  acl           = "private"
  tags          = module.global.tags
  force_destroy = true
  lifecycle_rule {
    id                                     = "cleanup"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1
    prefix                                 = ""
    expiration {
      days = var.lb_access_logs_expiration_days
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "lb_access_logs" {
  bucket = aws_s3_bucket.lb_access_logs.id
  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.lb_access_logs.arn}",
        "${aws_s3_bucket.lb_access_logs.arn}/*"
      ],
      "Principal": {
        "AWS": [ "${data.aws_elb_service_account.main.arn}" ]
      }
    }
  ]
}
POLICY
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port              = var.lb_port
  protocol          = var.lb_protocol

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

resource "aws_security_group_rule" "ingress_lb_http" {
  type              = "ingress"
  description       = var.lb_protocol
  from_port         = var.lb_port
  to_port           = var.lb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}