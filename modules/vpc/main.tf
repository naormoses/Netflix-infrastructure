resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "main" {
  count = var.aws_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 3)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-${count.index + 1}"
  }
}

resource "aws_main_route_table_association" "public_routetable" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public_routetable.id
}

resource "aws_route_table" "public_routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

