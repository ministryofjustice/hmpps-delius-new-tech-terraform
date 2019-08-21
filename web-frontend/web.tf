# Web SG Egress Rules 
resource "aws_security_group_rule" "web_mongo_out" {
  type                     = "egress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.newtech_casenotes.mongo_sg_id}"
  security_group_id        = "${data.terraform_remote_state.delius_core_security_groups.sg_newtech_web_id}"
}

resource "aws_security_group_rule" "web_pdfgenerator_out" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.newtech_pdf.pdf_sg_id}"
  security_group_id        = "${data.terraform_remote_state.delius_core_security_groups.sg_newtech_web_id}"
}

resource "aws_security_group_rule" "web_offenderapi_out" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.newtech_offenderapi.offenderapi_sg_id}"
  security_group_id        = "${data.terraform_remote_state.delius_core_security_groups.sg_newtech_web_id}"
}

# Target Ingress Rules - defined here to avoid circular dependency
resource "aws_security_group_rule" "offenderapi_web_in" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.delius_core_security_groups.sg_newtech_web_id}"
  security_group_id        = "${data.terraform_remote_state.newtech_offenderapi.offenderapi_sg_id}"
}

resource "aws_security_group_rule" "pdfgenerator_web_in" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.delius_core_security_groups.sg_newtech_web_id}"
  security_group_id        = "${data.terraform_remote_state.newtech_pdf.pdf_sg_id}"
}

resource "aws_security_group_rule" "mongo_web_in" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.delius_core_security_groups.sg_newtech_web_id}"
  security_group_id        = "${data.terraform_remote_state.newtech_casenotes.mongo_sg_id}"
}

# Ingress to Alfresco is via an externally facing ELB
# Therefore traffic from New Tech Web will originate from NAT GWs - existing rules apply

# ECS Config
resource "aws_ecs_task_definition" "web_task_def" {
  family                   = "${local.name_prefix}-newtechweb-pri-ecs"
  task_role_arn            = "${aws_iam_role.web_task_role.arn}"
  execution_role_arn       = "${aws_iam_role.web_execute_role.arn}"
  container_definitions    = "${data.template_file.web_task_def_template.rendered}"
  network_mode             = "awsvpc"
  memory                   = "${var.web_conf["memory"]}"
  cpu                      = "${var.web_conf["cpu"]}"
  requires_compatibilities = ["EC2"]
  tags                     = "${merge(var.tags, map("Name", "${local.name_prefix}-newtechweb-pri-ecs"))}"
}

resource "aws_ecs_service" "web_service" {
  name            = "${local.name_prefix}-newtechweb-pri-ecs"
  cluster         = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.web_task_def.arn}"

  # When new tag and arn formats are accepted in an environment - tags can be propagated
  # propagate_tags  = "TASK_DEFINITION"

  network_configuration = {
    subnets         = ["${local.private_subnet_ids}"]
    security_groups = ["${data.terraform_remote_state.delius_core_security_groups.sg_newtech_web_id}"]
  }
  depends_on = ["aws_iam_role.web_task_role"]
  service_registries {
    registry_arn   = "${aws_service_discovery_service.web_svc_record.arn}"
    container_name = "newtechweb"
  }
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_appautoscaling_target" "web_scaling_target" {
  min_capacity       = "${var.web_conf["ecs_scaling_min_capacity"]}"
  max_capacity       = "${var.web_conf["ecs_scaling_max_capacity"]}"
  resource_id        = "service/${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_name}/${aws_ecs_service.web_service.name}"
  role_arn           = "${aws_iam_role.web_execute_role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  # Use lifecycle rule as workaround for role_arn being changed every time due to
  # role_arn being required field but AWS will always switch this to the auto created service role
  lifecycle {
    ignore_changes = "role_arn"
  }
}

resource "aws_appautoscaling_policy" "web_scaling_policy" {
  name               = "${local.name_prefix}-newtechweb-pri-aas"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.web_scaling_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.web_scaling_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.web_scaling_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = "${var.web_conf["ecs_target_cpu"]}"
  }
}

# Create a service record in the ecs cluster's private namespace
resource "aws_service_discovery_service" "web_svc_record" {
  name = "newtechweb"

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
