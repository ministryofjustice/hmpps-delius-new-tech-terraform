resource "aws_security_group" "offenderapi_secure_lb_sg" {
  name        = "${local.name_prefix}-offapiseclb-pub-sg"
  description = "New Tech Offender API LB Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${local.name_prefix}-offapi-sec-lb-pub-sg"))}"
}

resource "aws_security_group_rule" "offenderapi_securelb_https_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${var.offender_api_allowed_secure_cidrs}"]
  security_group_id = "${aws_security_group.offenderapi_secure_lb_sg.id}"
}

resource "aws_security_group_rule" "offenderapi_securelb_http_out" {
  type                     = "egress"
  from_port                = "${var.offenderapi_conf["env_service_port"]}"
  to_port                  = "${var.offenderapi_conf["env_service_port"]}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.offenderapi_sg.id}"
  security_group_id        = "${aws_security_group.offenderapi_secure_lb_sg.id}"
}

resource "aws_lb_target_group" "offenderapi_secure_target_group" {
  name     = "${var.short_environment_name}-nt-api-secure"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  protocol = "HTTP"
  port     = "${var.offenderapi_conf["env_service_port"]}"
  tags     = "${merge(var.tags, map("Name", "${var.short_environment_name}-newtech-api-secure"))}"

  # Targets will be ECS tasks running in awsvpc mode so type needs to be ip
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path     = "/api/info"
    matcher  = "200-399"
  }
}

resource "aws_lb" "offenderapi_secure_alb" {
  name            = "${local.name_prefix}-offapisecpub-alb"
  internal        = false
  security_groups = ["${aws_security_group.offenderapi_secure_lb_sg.id}"]
  subnets         = ["${local.public_subnet_ids}"]
  tags            = "${merge(var.tags, map("Name", "${local.name_prefix}-offapi-sec-pub-alb"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "offenderapi_secure_lb_https_listener" {
  load_balancer_arn = "${aws_lb.offenderapi_secure_alb.arn}"
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

resource "aws_lb_listener_rule" "secure_lb_newtechweb_rule" {
  listener_arn = "${aws_lb_listener.offenderapi_secure_lb_https_listener.arn}"

  condition {
    field  = "path-pattern"
    values = ["/secure/*"]
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.offenderapi_secure_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "ping_lb_newtechweb_rule" {
  listener_arn = "${aws_lb_listener.offenderapi_secure_lb_https_listener.arn}"

  condition {
    field  = "path-pattern"
    values = ["/ping"]
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.offenderapi_secure_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "health_lb_newtechweb_rule" {
  listener_arn = "${aws_lb_listener.offenderapi_secure_lb_https_listener.arn}"

  condition {
    field  = "path-pattern"
    values = ["/health"]
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.offenderapi_secure_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "info_lb_newtechweb_rule" {
  listener_arn = "${aws_lb_listener.offenderapi_secure_lb_https_listener.arn}"

  condition {
    field  = "path-pattern"
    values = ["/info"]
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.offenderapi_secure_target_group.arn}"
  }
}

resource "aws_route53_record" "offenderapi_secure_alb_r53" {
  zone_id = "${local.public_zone_id}"
  name    = "community-api-secure.${local.external_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.offenderapi_secure_alb.dns_name}"]
}
