output "newtech_mongodb_endpoint" {
    value = "mongodb://mongodb.${data.terraform_remote_state.ecs_cluster.private_cluster_namespace["domain_name"]}"
}
output "mongo_sg_id" {
    value = "${aws_security_group.mongodb_sg.id}"
}