provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA47CR2PIOAETCHCJ5"
  secret_key = "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"
}
# Create a VPC
resource "aws_vpc" "TeeVPC" {
  cidr_block = "10.14.0.0/16"

  tags = {
    Name      = "TeeVPC"
    Project   = "p14"
    Terraform = "tf-tee"
  }
}
resource "aws_subnet" "Tee-Public-Subnet1" {
  vpc_id                  = aws_vpc.TeeVPC.id
  cidr_block              = "10.14.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name      = "Tee-pub-1"
    Terraform = "true"
  }
}

resource "aws_subnet" "Tee-Public_Subnets2" {
  vpc_id                  = aws_vpc.TeeVPC.id
  cidr_block              = "10.14.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name      = "Tee-pub-2"
    Terraform = "true"
  }
}
resource "aws_subnet" "Tee-Private_Subnets1" {
  vpc_id                  = aws_vpc.TeeVPC.id
  cidr_block              = "10.14.10.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name      = "Tee-pri-1"
    Terraform = "true"
  }
}
resource "aws_subnet" "Tee-Private_Subnets2" {
  vpc_id                  = aws_vpc.TeeVPC.id
  cidr_block              = "10.14.11.0/24"
  availability_zone       = "us-east-1c"

  tags = {
    Name      = "Tee-pri-2"
    Terraform = "true"
  }
}
#Create Internet Gateway
resource "aws_internet_gateway" "Tee-ig-tf" {
  vpc_id = aws_vpc.TeeVPC.id
  tags = {
    Name = "Tee-tf_igw"
  }
}

resource "aws_route_table" "tee-public_route_table" {
  vpc_id = aws_vpc.TeeVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Tee-ig-tf.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "tee_public_rtb"
    Terraform = "true"
  }
}

# resource "aws_route_table_association" "tee-rtb-ass-a" {
#   subnet_id      = aws_subnet.Tee-Public_Subnets1.id
#   route_table_id = aws_route_table.tee-public_route_table.id
# }

resource "aws_route_table_association" "tee-rtb-ass-b" {
  subnet_id      = aws_subnet.Tee-Public_Subnets2.id
  route_table_id = aws_route_table.tee-public_route_table.id
}

resource "aws_security_group" "sg69" {
 vpc_id      = aws_vpc.TeeVPC.id

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_network_interface" "Tee-Server-if" {
  subnet_id       = aws_subnet.Tee-Public_Subnets2.id
  security_groups = ["sg-000c30b1de5b2de45",aws_security_group.sg69.id]

  tags = {
    Name      = "Primary-ENI-69"
    Terraform = "tf-tee"
  }
}

resource "aws_instance" "TeeEC2" {
  ami           = "ami-04ff98ccbfa41c9ad"
  instance_type = "t2.micro"


  network_interface {
    network_interface_id = aws_network_interface.Tee-Server-if.id
    device_index         = 0
  }

  tags = {
    Name      = "Tee-EC2"
    Terraform = "tf-tee"
  }
}




