# Task security group
resource "aws_security_group" "pdf_sg" {
  name        = "${local.name_prefix}-pdfgen-pri-sg"
  description = "New Tech Casenotes Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_security_group_rule" "pdf_https_out" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.pdf_sg.id}"
}

resource "aws_security_group_rule" "pdf_dnssec_out" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.pdf_sg.id}"
}

resource "aws_security_group_rule" "pdf_dns_out" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.pdf_sg.id}"
}

resource "aws_ecs_task_definition" "pdf_task_def" {
  family                   = "${local.name_prefix}-pdfgen-pri-ecs"
  task_role_arn            = "${aws_iam_role.pdf_task_role.arn}"
  execution_role_arn       = "${aws_iam_role.pdf_execute_role.arn}"
  container_definitions    = "${data.template_file.pdf_task_def_template.rendered}"
  network_mode             = "awsvpc"
  memory                   = "${var.pdfgenerator_conf["memory"]}"
  cpu                      = "${var.pdfgenerator_conf["cpu"]}"
  requires_compatibilities = ["EC2"]
  tags                     = "${merge(var.tags, map("Name", "${local.name_prefix}-pdfgen-pri-ecs"))}"
}

resource "aws_ecs_service" "pdf_service" {
  name            = "${local.name_prefix}-pdfgen-pri-ecs"
  cluster         = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.pdf_task_def.arn}"

  # When new tag and arn formats are accepted in an environment - tags can be propagated
  # propagate_tags  = "TASK_DEFINITION"

  network_configuration = {
    subnets         = ["${local.private_subnet_ids}"]
    security_groups = ["${aws_security_group.pdf_sg.id}"]
  }
  depends_on = ["aws_iam_role.pdf_task_role"]
  service_registries {
    registry_arn   = "${aws_service_discovery_service.pdf_svc_record.arn}"
    container_name = "pdfgenerator"
  }
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_appautoscaling_target" "pdf_scaling_target" {
  min_capacity       = "${var.pdfgenerator_conf["ecs_scaling_min_capacity"]}"
  max_capacity       = "${var.pdfgenerator_conf["ecs_scaling_max_capacity"]}"
  resource_id        = "service/${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_name}/${aws_ecs_service.pdf_service.name}"
  role_arn           = "${aws_iam_role.pdf_execute_role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  
  # Use lifecycle rule as workaround for role_arn being changed every time due to
  # role_arn being required field but AWS will always switch this to the auto created service role
  lifecycle {
    ignore_changes = "role_arn"
  }
}

resource "aws_appautoscaling_policy" "pdf_scaling_policy" {
  name               = "${local.name_prefix}-pdfgen-pri-aas"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.pdf_scaling_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.pdf_scaling_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.pdf_scaling_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = "${var.pdfgenerator_conf["ecs_target_cpu"]}"
  }
}

# Create a service record in the ecs cluster's private namespace
resource "aws_service_discovery_service" "pdf_svc_record" {
  name = "pdfgenerator"

  dns_config {
    namespace_id = "${data.terraform_remote_state.ecs_cluster.private_cluster_namespace["id"]}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  # ECS service helath check
  health_check_custom_config {
    failure_threshold = 1
  }
}
