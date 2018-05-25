output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "private_subnet_a_id" {
  value = "${aws_subnet.private_a.id}"
}

output "private_subnet_b_id" {
  value = "${aws_subnet.private_b.id}"
}

output "public_subnet_a_id" {
  value = "${aws_subnet.public_a.id}"
}

output "public_subnet_b_id" {
  value = "${aws_subnet.public_b.id}"
}

output "db_subnet_group_name" {
  value = "${aws_db_subnet_group.default.name}"
}
