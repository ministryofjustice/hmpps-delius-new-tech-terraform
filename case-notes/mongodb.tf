resource "aws_security_group" "mongodb_sg" {
  name        = "${local.name_prefix}-cnotesdb-pri-sg"
  description = "New Tech Casenotes Mongo DB Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  # Allow inbound mongo client from casenotes task sg
  ingress {
    # TLS (change to whatever ports you need)
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = ["${aws_security_group.casenotes_sg.id}"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This task needs access to the EFS volumes for persistent storage
resource "aws_security_group_rule" "task_efssg_rule" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.mongodb_sg.id}"
  security_group_id        = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_efs_sg_id}"
}

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
    name = "mongodb-efs"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "rexray/efs"
    }
  }

  tags = "${merge(var.tags, map("Name", "${local.name_prefix}-cnotesdb-pri-ecs"))}"
}

resource "aws_ecs_service" "mongodb_service" {
  name    = "${local.name_prefix}-cnotesdb-pri-ecs"
  cluster = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"

  task_definition = "${aws_ecs_task_definition.mongodb_task_def.arn}"

  network_configuration = {
    subnets         = ["${local.db_subnet_ids}"]
    security_groups = ["${aws_security_group.mongodb_sg.id}"]
  }

  # Not horizontally scalable - single instance
  desired_count = 1
  depends_on    = ["aws_iam_role.mongodb_task_role"]

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
