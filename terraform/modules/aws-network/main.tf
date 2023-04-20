resource "aws_vpc" "vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "Project VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public_subnet_1" {
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_1
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_1_cidr_block
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_2_cidr_block
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_1
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_1_cidr_block
  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_2_cidr_block
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_1
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_3_cidr_block
  tags = {
    Name = "private_subnet_3"
  }
}

resource "aws_subnet" "private_subnet_4" {
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone_2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_4_cidr_block
  tags = {
    Name = "private_subnet_4"
  }
}

resource "aws_route_table" "aws_route_table" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat_1" {
  vpc = true
  tags = {
    Name = "nat_1"
  }
}

resource "aws_eip" "nat_2" {
  vpc = true
  tags = {
    Name = "nat_2"
  }
}

resource "aws_nat_gateway" "ngw_1" {
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.nat_1.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngw_2" {
  subnet_id     = aws_subnet.public_subnet_2.id
  allocation_id = aws_eip.nat_2.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private_rt_1"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private_rt_2"
  }
}

resource "aws_route" "private_1" {
  route_table_id         = aws_route_table.private_rt_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw_1.id
}

resource "aws_route" "private_2" {
  route_table_id         = aws_route_table.private_rt_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw_2.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Public Subnet ACL"
  }
}

resource "aws_network_acl_rule" "public_ingress_ssh" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_ingress_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_ingress_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 130
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}


resource "aws_network_acl_rule" "public_egress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"

}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private Subnet ACL"
  }
}


resource "aws_network_acl_rule" "private_ingress_app" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 140
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 5000
  to_port        = 5000
}

resource "aws_network_acl_rule" "private_ingress_postgres" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 200
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "private_ingress_ssh" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 160
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "private_ingress_http" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 170
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_ingress_https" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 180
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_egress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 190
  egress         = true
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
