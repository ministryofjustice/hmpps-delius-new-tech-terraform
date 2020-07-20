resource "aws_security_group" "offenderapi_public_lb_sg" {
  name        = "${local.name_prefix}-offapipublb-pub-sg"
  description = "Community API Public Load Balancer - no inbound restrictions"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${local.name_prefix}-offapipublb-pub-sg"))}"
}

resource "aws_security_group_rule" "offenderapi_public_lb_https_in" {
  count             = "${var.offenderapi_conf["enable_public_lb"] ? 1 : 0}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.offenderapi_public_lb_sg.id}"
}

resource "aws_security_group_rule" "offenderapilb_public_lb_http_out" {
  type                     = "egress"
  from_port                = "${var.offenderapi_conf["env_service_port"]}"
  to_port                  = "${var.offenderapi_conf["env_service_port"]}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.offenderapi_sg.id}"
  security_group_id        = "${aws_security_group.offenderapi_public_lb_sg.id}"
}

resource "aws_lb_target_group" "offenderapi_public_target_group" {
  name     = "${var.short_environment_name}-nt-api-public"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  protocol = "HTTP"
  port     = "${var.offenderapi_conf["env_service_port"]}"
  tags     = "${merge(var.tags, map("Name", "${var.short_environment_name}-newtech-api-public"))}"

  # Targets will be ECS tasks running in awsvpc mode so type needs to be ip
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path     = "/health/ping"
    matcher  = "200-399"
  }
}

resource "aws_lb" "offenderapi_public_alb" {
  name            = "${local.name_prefix}-offapi-pub-open-alb"
  internal        = false
  security_groups = ["${aws_security_group.offenderapi_public_lb_sg.id}"]
  subnets         = ["${local.public_subnet_ids}"]
  tags            = "${merge(var.tags, map("Name", "${local.name_prefix}-offapi-pub-open-alb"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "offenderapi_public_lb_https_listener" {
  load_balancer_arn = "${aws_lb.offenderapi_public_alb.arn}"
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

resource "aws_lb_listener_rule" "offenderapi_public_lb_swagger_rule" {
  listener_arn = "${aws_lb_listener.offenderapi_public_lb_https_listener.arn}"

  condition {
    path_pattern {
      values = [
        "/swagger-*",
        "/v2/api-docs",
        "/webjars/springfox-swagger-ui/*"
      ]
    }
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.offenderapi_public_target_group.arn}"
  }
}

resource "aws_route53_record" "offenderapi_public_alb_r53" {
  count   = "${var.offenderapi_conf["enable_public_lb"] ? 1 : 0}"
  zone_id = "${local.public_zone_id}"
  name    = "community-api-public.${local.external_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.offenderapi_public_alb.dns_name}"]
}
