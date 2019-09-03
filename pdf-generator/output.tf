output "newtech_pdf_endpoint" {
    value = "http://pdfgenerator.${data.terraform_remote_state.ecs_cluster.private_cluster_namespace["domain_name"]}:${var.pdfgenerator_conf["env_service_port"]}"
}

output "pdf_sg_id" {
    value = "${aws_security_group.pdf_sg.id}"
}