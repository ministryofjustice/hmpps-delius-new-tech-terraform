output "newtech_search_config" {
  value = {
    securitygroup_id = "${aws_security_group.search_sg.id}"
    domain_arn       = "${aws_elasticsearch_domain.search_domain.arn}"
    domain_id        = "${aws_elasticsearch_domain.search_domain.domain_id}"
    domain_name      = "${aws_elasticsearch_domain.search_domain.domain_name}"
    endpoint         = "${aws_elasticsearch_domain.search_domain.endpoint}"
    kibana_endpoint  = "${aws_elasticsearch_domain.search_domain.kibana_endpoint}"
    cloudplatform_pcs_search_role_name = "${aws_iam_role.cloudplatform_offender_search_role.name}"
  }
}
