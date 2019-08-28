resource "aws_security_group" "mongodb_sg" {
  name        = "${local.name_prefix}-cnotesdb-pri-sg"
  description = "New Tech Casenotes Mongo DB Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_security_group_rule" "mongodb_https_out" {
  type            = "egress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.mongodb_sg.id}"
}

resource "aws_security_group_rule" "mongodb_dnssec_out" {
  type            = "egress"
  from_port       = 53
  to_port         = 53
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.mongodb_sg.id}"
}

resource "aws_security_group_rule" "mongodb_dns_out" {
  type            = "egress"
  from_port       = 53
  to_port         = 53
  protocol        = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.mongodb_sg.id}"
}

resource "aws_security_group_rule" "mongodb_casenotes_in" {
  type            = "ingress"
  from_port       = 27017
  to_port         = 27017
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.casenotes_sg.id}"
  security_group_id = "${aws_security_group.mongodb_sg.id}"
}

# When EFS encryption is supported by rexray volume driver, should switch from EBC
# This task needs access to the EFS volumes for persistent storage
# resource "aws_security_group_rule" "task_efssg_rule" {
#   type                     = "ingress"
#   from_port                = 2049
#   to_port                  = 2049
#   protocol                 = "tcp"
#   source_security_group_id = "${aws_security_group.mongodb_sg.id}"
#   security_group_id        = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_efs_sg_id}"
# }

resource "aws_ecs_task_definition" "mongodb_task_def" {
  family        = "${local.name_prefix}-cnotesdb-pri-ecs"
  task_role_arn = "${aws_iam_role.mongodb_task_role.arn}"

  # Launch with the same execution role as the casenotes task - common requirements and same overarchig app
  execution_role_arn       = "${aws_iam_role.casenotes_execute_role.arn}"
  container_definitions    = "${data.template_file.mongodb_task_def_template.rendered}"
  network_mode             = "awsvpc"
  memory                   = "${var.mongodb_conf["memory"]}"
  cpu                      = "${var.mongodb_conf["cpu"]}"
  requires_compatibilities = ["EC2"]

  volume {
    name = "${local.name_prefix}-cnotesdb-pri-ebs"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "cloudstor:aws"

      driver_opts {
        ebstype = "gp2"
        backing = "relocatable"
        size    = 10
      }
    }
  }

  tags = "${merge(var.tags, map("Name", "${local.name_prefix}-cnotesdb-pri-ecs"))}"
}

resource "aws_ecs_service" "mongodb_service" {
  name    = "${local.name_prefix}-cnotesdb-pri-ecs"
  cluster = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"

  task_definition = "${aws_ecs_task_definition.mongodb_task_def.arn}"

  # When new tag and arn formats are accepted in an environment - tags can be propagated
  # propagate_tags  = "TASK_DEFINITION"

  network_configuration = {
    subnets         = ["${local.db_subnet_ids}"]
    security_groups = ["${aws_security_group.mongodb_sg.id}"]
  }
  # Not horizontally scalable - single instance
  desired_count = 1
  depends_on    = ["aws_iam_role.mongodb_task_role"]

  service_registries {
    registry_arn = "${aws_service_discovery_service.mongodb_svc_record.arn}"
    container_name = "mongodb"
  }
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_service_discovery_service" "mongodb_svc_record" {
  name = "mongodb"

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
