resource "aws_route_table" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public"))}"
}

resource "aws_route" "public2gateway" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_c" {
  count          = "${var.az_count == 3 ? 1 : 0}"
  subnet_id      = "${aws_subnet.public_c.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private"))}"
}

resource "aws_route" "private2natgateway" {
  route_table_id = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.gw.id}"
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = "${aws_subnet.private_a.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = "${aws_subnet.private_b.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private_c" {
  count          = "${var.az_count == 3 ? 1 : 0}"
  subnet_id      = "${aws_subnet.private_c.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table" "db" {
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_db"))}"
}

resource "aws_route_table_association" "db_a_fs" {
  count          = "${var.az_count == 3 ? 1 : 0}"
  subnet_id      = "${aws_subnet.db_a_fs.id}"
  route_table_id = "${aws_route_table.db.id}"
}

resource "aws_route_table_association" "db_a_cd" {
  count          = "${var.az_count == 3 ? 0 : 1}"
  subnet_id      = "${aws_subnet.db_a_cd.id}"
  route_table_id = "${aws_route_table.db.id}"
}

resource "aws_route_table_association" "db_b_fs" {
  count          = "${var.az_count == 3 ? 1 : 0}"
  subnet_id      = "${aws_subnet.db_b_fs.id}"
  route_table_id = "${aws_route_table.db.id}"
}

resource "aws_route_table_association" "db_b_cd" {
  count          = "${var.az_count == 3 ? 0 : 1}"
  subnet_id      = "${aws_subnet.db_b_cd.id}"
  route_table_id = "${aws_route_table.db.id}"
}

resource "aws_route_table_association" "db_c" {
  count          = "${var.az_count == 3 ? 1 : 0}"
  subnet_id      = "${aws_subnet.db_c.id}"
  route_table_id = "${aws_route_table.db.id}"
}
