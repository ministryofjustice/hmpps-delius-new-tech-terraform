resource "aws_vpc_peering_connection" "engineering" {
  vpc_id        = "${module.network.vpc_id}"
  peer_owner_id = "${var.engineering_account_id}"
  peer_vpc_id   = "${var.ci_vpc_id}"
  tags          = "${merge(var.tags, map("Name", "${local.environment_name}_engineering"))}"
}

resource "aws_vpc_peering_connection" "bastion" {
  vpc_id = "${module.network.vpc_id}"
  peer_owner_id = "${var.engineering_account_id}"
  peer_vpc_id = "${var.bastion_vpc_id}"
  tags          = "${merge(var.tags, map("Name", "${local.environment_name}_bastion"))}"
}

resource "aws_route" "this2engineering" {
  route_table_id = "${module.network.private_route_table_id}"
  destination_cidr_block = "${var.ci_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.engineering.id}"
}

resource "aws_route" "this2bastion" {
  route_table_id = "${module.network.private_route_table_id}"
  destination_cidr_block = "${var.bastion_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion.id}"
}
