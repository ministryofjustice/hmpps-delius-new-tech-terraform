resource "aws_security_group" "offenderapi_lb_sg" {
  name        = "${local.name_prefix}-offapilb-pub-sg"
  description = "New Tech Offender API LB Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${local.name_prefix}-offapilb-pub-sg"))}"
}

resource "aws_security_group_rule" "offenderapilb_https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${var.offender_api_allowed_cidrs}"]
  security_group_id = "${aws_security_group.offenderapi_lb_sg.id}"
}

resource "aws_security_group_rule" "offenderapilb_http_out" {
  type                     = "egress"
  from_port                = "${var.offenderapi_conf["env_service_port"]}"
  to_port                  = "${var.offenderapi_conf["env_service_port"]}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.offenderapi_sg.id}"
  security_group_id        = "${aws_security_group.offenderapi_lb_sg.id}"
}

resource "aws_lb_target_group" "offenderapi_target_group" {
  name     = "${var.short_environment_name}-newtech-api"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  protocol = "HTTP"
  port     = "${var.offenderapi_conf["env_service_port"]}"
  tags     = "${merge(var.tags, map("Name", "${var.short_environment_name}-newtech-api"))}"

  # Targets will be ECS tasks running in awsvpc mode so type needs to be ip
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path     = "/api/info"
    matcher  = "200-399"
  }
}

resource "aws_lb" "offenderapi_alb" {
  name            = "${local.name_prefix}-offapi-pub-alb"
  internal        = false
  security_groups = ["${aws_security_group.offenderapi_lb_sg.id}"]
  subnets         = ["${local.public_subnet_ids}"]
  tags            = "${merge(var.tags, map("Name", "${local.name_prefix}-offapi-pub-alb"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "offenderapi_lb_https_listener" {
  load_balancer_arn = "${aws_lb.offenderapi_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${local.public_certificate_arn}"
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
    }
  }
}

resource "aws_lb_listener_rule" "internal_lb_newtechweb_rule" {
  listener_arn = "${aws_lb_listener.offenderapi_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.offenderapi_target_group.arn}"
  }
}

resource "aws_route53_record" "offenderapi_alb_r53" {
  zone_id = "${local.public_zone_id}"
  name    = "community-api.${local.external_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.offenderapi_alb.dns_name}"]
}
