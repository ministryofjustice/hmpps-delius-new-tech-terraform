# Task security group
resource "aws_security_group" "casenotes_sg" {
  name        = "${local.name_prefix}-casenotes-pri-sg"
  description = "New Tech Casenoets Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  network_configuration = {
    subnets = [ "${local.private_subnet_ids}" ]
    security_groups = [ "${aws_security_group.casenotes_sg.id}" ]
  }
  # Not horizontally scalable - single instance
  desired_count = 1
  depends_on    = ["aws_iam_role.casenotes_task_role"]
  
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}
