provider "aws" {
  region  = var.region
  profile = "dev"
}

resource "aws_vpc" "paytm_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "paytm_vpc"
  }

}

resource "aws_internet_gateway" "paytm_igw" {
  vpc_id = aws_vpc.paytm_vpc.id
  tags = {
    Name = "paytm_igw"
  }
}

resource "aws_subnet" "paytm_public_subnet1" {
  vpc_id                  = aws_vpc.paytm_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "bastion_subnet_1a"
  }
}

resource "aws_subnet" "paytm_public_subnet2" {
  vpc_id                  = aws_vpc.paytm_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "bastion_subnet_1b"
  }
}
resource "aws_subnet" "paytm_client_subnet1" {
  vpc_id            = aws_vpc.paytm_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.azs[0]
  tags = {
    Name = "client_subnet_1a"
  }
}
resource "aws_subnet" "paytm_client_subnet2" {
  vpc_id            = aws_vpc.paytm_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.azs[1]
  tags = {
    Name = "client_subnet_1b"
  }
}
resource "aws_subnet" "paytm_backend_subnet1" {
  vpc_id            = aws_vpc.paytm_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.azs[0]
  tags = {
    Name = "backend_subnet_1a"
  }
}
resource "aws_subnet" "paytm_backend_subnet2" {
  vpc_id            = aws_vpc.paytm_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = var.azs[1]

  tags = {
    Name = "backend_subnet_1b"
  }
}
resource "aws_subnet" "paytm_database_subnet1" {
  vpc_id            = aws_vpc.paytm_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = var.azs[0]
  tags = {
    Name = "database_subnet_1a"
  }
}
resource "aws_subnet" "paytm_database_subnet2" {
  vpc_id            = aws_vpc.paytm_vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = var.azs[1]
  tags = {
    Name = "database_subnet_1b"
  }
}


resource "aws_route_table" "paytm_public_rt" {
  vpc_id = aws_vpc.paytm_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.paytm_igw.id
  }

  tags = {
    Name = "paytm_public_rt"
  }
}

resource "aws_eip" "paytm_eip" {
  domain = "vpc"
  tags = {
    Name = "paytm_eip"
  }


}

resource "aws_nat_gateway" "paytm_nat_gateway" {
  allocation_id = aws_eip.paytm_eip.id
  subnet_id     = aws_subnet.paytm_public_subnet1.id
  depends_on    = [aws_internet_gateway.paytm_igw]
  tags = {
    Name = "paytm_nat_gateway"
  }
}

resource "aws_route_table" "paytm_private_rt" {
  vpc_id = aws_vpc.paytm_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.paytm_nat_gateway.id

  }

  tags = {
    Name = "paytm_private_rt"
  }
}


resource "aws_route_table_association" "paytm_public_rt_assoc" {
  for_each = {
    public1 = aws_subnet.paytm_public_subnet1.id
    public2 = aws_subnet.paytm_public_subnet2.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.paytm_public_rt.id
}

resource "aws_route_table_association" "paytm_private_rt_assoc" {
  for_each = {
    client1  = aws_subnet.paytm_client_subnet1.id
    client2  = aws_subnet.paytm_client_subnet2.id
    backend1 = aws_subnet.paytm_backend_subnet1.id
    backend2 = aws_subnet.paytm_backend_subnet2.id
    db1      = aws_subnet.paytm_database_subnet1.id
    db2      = aws_subnet.paytm_database_subnet2.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.paytm_private_rt.id
}

resource "aws_security_group" "paytm_bastion_public_sg" {
  name        = "bastion_public_sg"
  description = "Security group for bastion host in public subnet"
  vpc_id      = aws_vpc.paytm_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_public_sg"
  }
}


resource "aws_security_group" "paytm_client_sg" {
  name        = "client_sg"
  description = "Security group for client tier"
  vpc_id      = aws_vpc.paytm_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.paytm_bastion_public_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.paytm_frontend_alb_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.paytm_backend_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "client_sg"
  }

}


resource "aws_security_group" "paytm_backend_sg" {
  name        = "backend_sg"
  description = "Security group for backend tier"
  vpc_id      = aws_vpc.paytm_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.paytm_client_sg.id, aws_security_group.paytm_backend_alb_sg.id]
  }

//Custome Port
 ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.paytm_client_sg.id]
  }


  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.paytm_bastion_public_sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "backend_sg"
  }

}


resource "aws_security_group" "paytm_database_sg" {
  name        = "database_sg"
  description = "Security group for backend tier"
  vpc_id      = aws_vpc.paytm_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.paytm_backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_sg"
  }

}

resource "aws_security_group" "paytm_frontend_alb_sg" {
  name        = "frontend_alb_sg"
  description = "Security group for frontend ALB"
  vpc_id      = aws_vpc.paytm_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "frontend_alb_sg"
  }

}

resource "aws_security_group" "paytm_backend_alb_sg" {
  name        = "backend_alb_sg"
  description = "Security group for backend ALB"
  vpc_id      = aws_vpc.paytm_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "backend_alb_sg"
  }
}


//Data source to fetch latest amazon linux 2 AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}


//Creating instances

resource "aws_instance" "bastion_host" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.paytm_public_subnet1.id
  security_groups = [aws_security_group.paytm_bastion_public_sg.id]

  tags = {
    Name = "bastion_host"
  }
}

resource "aws_instance" "frontend" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.paytm_client_subnet1.id
  security_groups = [aws_security_group.paytm_client_sg.id]

  tags = {
    Name = "frontend_instance"
  }
}

resource "aws_instance" "backend" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.paytm_backend_subnet1.id
  security_groups = [aws_security_group.paytm_backend_sg.id]

  tags = {
    Name = "backend_instance"
  }
}


