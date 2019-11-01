output "newtech_offenderapi_endpoint" {
  value = "http://offenderapi.${data.terraform_remote_state.ecs_cluster.private_cluster_namespace["domain_name"]}:${var.offenderapi_conf["env_service_port"]}"
}

output "offenderapi_sg_id" {
  value = "${aws_security_group.offenderapi_sg.id}"
}

output "offenderapi_secure_fqdn" {
  value = "${aws_route53_record.offenderapi_secure_alb_r53.fqdn}"
}

output "offenderapi_fqdn" {
  value = "${aws_route53_record.offenderapi_alb_r53.fqdn}"
}

output "short_environment_name" {
  value = "${var.short_environment_name}"
}
