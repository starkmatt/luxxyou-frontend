# VPC
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-VPC"
  }
}

# Elastic IP
resource "aws_eip" "main" {
  vpc = true
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "${var.project_name}-IGW"
  }
}

# NAT Gateway
#resource "aws_nat_gateway" "main" {
#  allocation_id           = "${aws_eip.main.id}"
#  subnet_id               = "${aws_subnet.public[0].id}"
#  tags = {
#    Name = "${var.project_name}-NAT"
#  }
# }

# Subnet(s) - Private
#resource "aws_subnet" "private" {
#  count = "${length(var.subnet_private_cidr)}"
#  vpc_id = "${aws_vpc.main.id}"
#  cidr_block = "${element(var.subnet_private_cidr,count.index)}"
#  availability_zone = "${element(var.azs,count.index)}"
#  tags = {
#    Name = "${var.subnet_private_name[count.index]}"
#  }
#}

# Subnet(s) - Public
resource "aws_subnet" "public" {
  count = "${length(var.subnet_public_cidr)}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${element(var.subnet_public_cidr,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "${var.subnet_public_name[count.index]}"
  }
}

# Route Table - Attach Internet Gateway 
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "${var.cidr_block_all}"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags = {
    Name = "${var.project_name}-RT-public"
  }
}

# Route Table - Attach NAT Gateway
#resource "aws_route_table" "private" {
#  vpc_id = "${aws_vpc.main.id}"
#  route {
#    cidr_block = "${var.cidr_block_all}"
#    nat_gateway_id = "${aws_nat_gateway.main.id}"
#  }
#  tags = {
#    Name = "${var.project_name}-RT-private" 
#  }
#}

# Route Table Association - Public
resource "aws_route_table_association" "public" {
  count = "${length(var.subnet_public_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Route Table Association - Private
#resource "aws_route_table_association" "private" {
#  count = "${length(var.subnet_private_cidr)}"
#  subnet_id      = "${element(aws_subnet.private.*.id,count.index)}"
#  route_table_id = "${aws_route_table.private.id}"
#}


# Security Group - Inbound

resource "aws_security_group" "inbound" {
  name        = "${var.project_name}-inbound"
  description = "Inbound access"
  vpc_id      = "${aws_vpc.main.id}"

 ingress {
    from_port       = 443
    to_port         = 443 
    protocol        = "tcp" 
    cidr_blocks     = ["${var.cidr_block_all}"] 
    description     = "Inbound"
    }

 ingress {
    from_port       = 80
    to_port         = 80 
    protocol        = "tcp" 
    cidr_blocks     = ["${var.cidr_block_all}"] 
    description     = "Inbound"
    }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "tcp"
    cidr_blocks = ["${var.cidr_block_all}"]
    }

  tags = {
    Name = "${var.project_name}-luxxyou-inbound"
  }
}



# ACL Network - Public
resource "aws_network_acl" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  subnet_ids = "${aws_subnet.public.*.id}"

ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 80
    to_port    = 80
  }


ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 443
    to_port    = 443
  }


ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 32768
    to_port    = 65535
  }


  egress {
    protocol   = "tcp"
    rule_no    = "${var.rule_no_acl}"
    action     = "allow"
    cidr_block = "${var.cidr_block_all}"
    from_port  = 0
    to_port    = 0
  }


  tags = {
    Name = "${var.project_name}-ACL-Public-Access" 
  }
}

# ACL Network - Private
#resource "aws_network_acl" "private" {
#  vpc_id     = "${aws_vpc.main.id}"
#  subnet_ids = "${aws_subnet.private.*.id}"
#
#ingress {
#    protocol   = tcp
#    rule_no    = "${var.rule_no_acl}"
#    action     = "allow"
#    cidr_block = "${var.cidr_block_all}"
#    from_port  = 0
#    to_port    = 0
#  }
#
#  egress {
#    protocol   = tcp
#    rule_no    = "${var.rule_no_acl}"
#    action     = "allow"
#    cidr_block = "${var.cidr_block_all}"
#    from_port  = 0
#    to_port    = 0
#  }
#
#  tags = {
#    Name = "${var.project_name}-ACL-Private-Access" 
#}
# }