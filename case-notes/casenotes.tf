# Task security group
resource "aws_security_group" "casenotes_sg" {
  name        = "${local.name_prefix}-casenotes-pri-sg"
  description = "New Tech Casenotes Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${local.name_prefix}-casenotes-pri-sg"))}"
}

resource "aws_security_group_rule" "casenotes_https_out" {
  type            = "egress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.casenotes_sg.id}"
}

resource "aws_security_group_rule" "casenotes_dnssec_out" {
  type            = "egress"
  from_port       = 53
  to_port         = 53
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.casenotes_sg.id}"
}

resource "aws_security_group_rule" "casenotes_dns_out" {
  type            = "egress"
  from_port       = 53
  to_port         = 53
  protocol        = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.casenotes_sg.id}"
}

resource "aws_security_group_rule" "casenotes_mongo_out" {
  type            = "egress"
  from_port       = 27017
  to_port         = 27017
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.mongodb_sg.id}"
  security_group_id = "${aws_security_group.casenotes_sg.id}"
}

resource "aws_ecs_task_definition" "casenotes_task_def" {
  family                   = "${local.name_prefix}-casenotes-pri-ecs"
  task_role_arn            = "${aws_iam_role.casenotes_task_role.arn}"
  execution_role_arn       = "${aws_iam_role.casenotes_execute_role.arn}"
  container_definitions    = "${data.template_file.casenotes_task_def_template.rendered}"
  network_mode             = "awsvpc"
  memory                   = "${var.casenotes_conf["memory"]}"
  cpu                      = "${var.casenotes_conf["cpu"]}"
  requires_compatibilities = ["EC2"]
  tags                     = "${merge(var.tags, map("Name", "${local.name_prefix}-casenotes-pri-ecs"))}"
}

resource "aws_ecs_service" "casenotes_service" {
  name            = "${local.name_prefix}-casenotes-pri-ecs"
  cluster         = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.casenotes_task_def.arn}"

  # When new tag and arn formats are accepted in an environment - tags can be propagated
  # propagate_tags  = "TASK_DEFINITION"

  network_configuration = {
    subnets         = ["${local.private_subnet_ids}"]
    security_groups = [
      "${aws_security_group.casenotes_sg.id}",
      "${data.terraform_remote_state.delius_core_security_groups.sg_newtech_casenotes_out_id}"
      ]
  }
  # Disabled as have new case notes to probation service in cloud platform
  desired_count = 0
  depends_on    = ["aws_iam_role.casenotes_task_role"]
  service_registries {
    registry_arn = "${aws_service_discovery_service.casenotes_svc_record.arn}"
    container_name = "casenotes"
  }
}

# Create a service record in the ecs cluster's private namespace
resource "aws_service_discovery_service" "casenotes_svc_record" {
  name = "casenotes"

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
