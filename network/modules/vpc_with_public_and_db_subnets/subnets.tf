resource "aws_subnet" "public_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 0)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_a", "Type", "public"))}"
}

resource "aws_subnet" "public_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_b", "Type", "public"))}"
}

resource "aws_subnet" "public_c" {
  count             = "${var.az_count == 3 ? 1 : 0}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 2)}"
  availability_zone = "${var.az_c}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_c", "Type", "public"))}"
}

resource "aws_subnet" "private_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 3)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_a", "Type", "private"))}"
}

resource "aws_subnet" "private_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 4)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_b", "Type", "private"))}"
}

resource "aws_subnet" "private_c" {
  count             = "${var.az_count == 3 ? 1 : 0}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 5)}"
  availability_zone = "${var.az_c}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_c", "Type", "private"))}"
}

# Terraform is not quite clever enough to realise that it doesn't need to check unused CIDRs for  >= /28 validity

resource "aws_subnet" "db_a_fs" {
  count             = "${var.az_count == 3 ? 1 : 0}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 12)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_db_a", "Type", "DB"))}"
}

resource "aws_subnet" "db_a_cd" {
  count             = "${var.az_count == 3 ? 0 : 1}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 6)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_db_a", "Type", "DB"))}"
}

resource "aws_subnet" "db_b_fs" {
  count             = "${var.az_count == 3 ? 1 : 0}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 13)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_db_b", "Type", "DB"))}"
}

resource "aws_subnet" "db_b_cd" {
  count             = "${var.az_count == 3 ? 0 : 1}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 7)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_db_b", "Type", "DB"))}"
}

resource "aws_subnet" "db_c" {
  count             = "${var.az_count == 3 ? 1 : 0}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 14)}"
  availability_zone = "${var.az_c}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_db_c", "Type", "DB"))}"
}
