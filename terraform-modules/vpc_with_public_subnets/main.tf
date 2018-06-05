resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags       = "${merge(var.tags, map("Name", "${var.environment_name}"))}"
}

resource "aws_internet_gateway" "main" {
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}"))}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id     = "${aws_eip.nat.id}"
  subnet_id         = "${aws_subnet.public_a.id}"
  depends_on        = ["aws_internet_gateway.main"]
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}"))}"
}

resource "aws_subnet" "public_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 0)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_a"))}"
}

resource "aws_route_table" "public_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = "${aws_internet_gateway.main.id}"
  }
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_a"))}"
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public_a.id}"
}

resource "aws_subnet" "public_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 1)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_b"))}"
}

resource "aws_route_table" "public_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = "${aws_internet_gateway.main.id}"
  }
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_b"))}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public_b.id}"
}

resource "aws_subnet" "private_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 2)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_a"))}"
}

resource "aws_route_table" "private_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_a"))}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = "${aws_subnet.private_a.id}"
  route_table_id = "${aws_route_table.private_a.id}"
}

resource "aws_subnet" "private_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 3)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_b"))}"
}

resource "aws_route_table" "private_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_b"))}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = "${aws_subnet.private_b.id}"
  route_table_id = "${aws_route_table.private_b.id}"
}

