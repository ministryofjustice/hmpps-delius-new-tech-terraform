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
  family                = "${local.name_prefix}-casenotes-pri-ecs"
  name                  = "casenotes"
  task_role_arn         = "${aws_iam_role.casenotes_task_role.arn}"
  execution_role_arn    = "${aws_iam_role.casenotes_execute_role.arn}"
  container_definitions = "${data.template_file.casenotes_task_def_template.rendered}"
  network_mode          = "awsvpc"
  tags = "${merge(var.tags, map("Name", "${local.name_prefix}-casenotes-pri-ecs"))}"
}

resource "aws_ecs_service" "casenotes_service" {
  name            = "${local.name_prefix}-casenotes-pri-ecs"
  cluster         = "${data.terraform_remote_state.ecs_cluster.shared_cluster}"
  task_definition = "${aws_ecs_task_definition.casenotes_task_def.arn}"

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}
