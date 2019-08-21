
output "mongo_sg_id" {
    value = "${aws_security_group.mongodb_sg.id}"
}