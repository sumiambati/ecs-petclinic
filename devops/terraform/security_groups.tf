resource "aws_security_group" "lb" {
  name        = "${var.app}-${var.environment}-lb"
  vpc_id      = var.vpc
  tags = module.global.tags
}

resource "aws_security_group" "task" {
  name        = "${var.app}-${var.environment}-task"
  vpc_id      = var.vpc
  tags = module.global.tags
}

resource "aws_security_group_rule" "lb_egress_rule" {
  type                     = "egress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.task.id
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "task_ingress_rule" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id
  security_group_id = aws_security_group.task.id
}

resource "aws_security_group_rule" "task_egress_rule" {
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task.id
}