resource "aws_lb_target_group" "offender_search_target_group" {
  name     = "${var.short_environment_name}-nt-offendersearch"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  protocol = "HTTP"
  port     = "${var.offendersearch_conf["env_service_port"]}"
  tags     = "${merge(var.tags, map("Name", "${var.short_environment_name}-newtech-offender-search"))}"

  # Targets will be ECS tasks running in awsvpc mode so type needs to be ip
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path     = "/health/ping"
    matcher  = "200-399"
  }
}

resource "aws_lb" "offender_search_alb" {
  name            = "${local.name_prefix}-offendersearch-alb"
  internal        = false
  security_groups = ["${aws_security_group.sg_offendersearch.id}"]
  subnets         = ["${local.public_subnet_ids}"]
  tags            = "${merge(var.tags, map("Name", "${local.name_prefix}-offendersearch-pub-alb"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "offender_search_lb_https_listener" {
  load_balancer_arn = "${aws_lb.offender_search_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${local.public_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.offender_search_target_group.arn}"
  }
}

resource "aws_route53_record" "offender_search_alb_r53" {
  zone_id = "${local.public_zone_id}"
  name    = "offender-search.${local.external_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.offender_search_alb.dns_name}"]
}
