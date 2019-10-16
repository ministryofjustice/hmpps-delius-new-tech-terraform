# Localised Task security group for changes w/out dependency on delius core sgs

resource "aws_security_group" "offenderpoll_sg" {
  name        = "${local.name_prefix}-offpoll-pri-sg"
  description = "New Tech Offender PollPush Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${local.name_prefix}-offenderpoll-pri-sg"))}"
}

resource "aws_security_group_rule" "offenderpoll_https_out" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.offenderpoll_sg.id}"
}

resource "aws_security_group_rule" "offenderpoll_dnssec_out" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.offenderpoll_sg.id}"
}

resource "aws_security_group_rule" "offenderpoll_dns_out" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.offenderpoll_sg.id}"
}

resource "aws_security_group_rule" "offenderpoll_offapi_out" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.newtech_offapi.offenderapi_sg_id}"
  security_group_id        = "${aws_security_group.offenderpoll_sg.id}"
}

resource "aws_security_group_rule" "offenderpoll_offapi_in" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.offenderpoll_sg.id}"
  security_group_id        = "${data.terraform_remote_state.newtech_offapi.offenderapi_sg_id}"
}

resource "aws_security_group_rule" "offenderpoll_searchin" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.offenderpoll_sg.id}"
  security_group_id        = "${data.terraform_remote_state.newtech_search.newtech_search_config["securitygroup_id"]}"
}

resource "aws_ecs_task_definition" "offenderpoll_task_def" {
  family                   = "${local.name_prefix}-offpoll-pri-ecs"
  task_role_arn            = "${aws_iam_role.offenderpollpush_task_role.arn}"
  execution_role_arn       = "${aws_iam_role.offenderpollpush_execute_role.arn}"
  container_definitions    = "${data.template_file.offenderpollpush_task_def_template.rendered}"
  network_mode             = "awsvpc"
  memory                   = "${var.offenderpollpush_conf["memory"]}"
  cpu                      = "${var.offenderpollpush_conf["cpu"]}"
  requires_compatibilities = ["EC2"]
  tags                     = "${merge(var.tags, map("Name", "${local.name_prefix}-offpoll-pri-ecs"))}"
}

resource "aws_ecs_service" "offenderpoll_service" {
  name            = "${local.name_prefix}-offpoll-pri-ecs"
  cluster         = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.offenderpoll_task_def.arn}"

  # When new tag and arn formats are accepted in an environment - tags can be propagated
  # propagate_tags  = "TASK_DEFINITION"

  network_configuration = {
    subnets         = ["${local.private_subnet_ids}"]
    security_groups = ["${aws_security_group.offenderpoll_sg.id}"]
  }
  # Not horizontally scalable - single instance
  desired_count = 1
  depends_on    = ["aws_iam_role.offenderpollpush_task_role"]
  service_registries {
    registry_arn   = "${aws_service_discovery_service.offenderpoll_svc_record.arn}"
    container_name = "offenderpollpush"
  }
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

# Create a service record in the ecs cluster's private namespace
resource "aws_service_discovery_service" "offenderpoll_svc_record" {
  name = "offenderpollpush"

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
