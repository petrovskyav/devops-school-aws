resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge( var.global_tags,
    {
      Name = "VPC for ${var.project} project"
    },
  )
}

resource "aws_subnet" "subnet" {
    count = length(var.subnets)
    vpc_id = "${aws_vpc.main.id}"

    cidr_block = "${values(var.subnets)[count.index]}"
    map_public_ip_on_launch = "true"
    availability_zone = "${var.region}${keys(var.subnets)[count.index]}"
    tags = merge( var.global_tags,
      {
        Name = "Subnet ${keys(var.subnets)[count.index]} for ${var.project} project"
      },
    )
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main.id}"
    tags = merge( var.global_tags,
      {
        Name = "IGW for ${var.project} project"
      },
    )
}

resource "aws_route_table" "public-rt" {
    vpc_id = "${aws_vpc.main.id}"
    
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = "${aws_internet_gateway.igw.id}" 
    }

    tags = merge( var.global_tags,
      {
        Name = "Routing table for ${var.project} project"
      },
    )
}

resource "aws_route_table_association" "rt_assoc"{
  count = "${length(aws_subnet.subnet)}"
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
