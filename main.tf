# Generate a new RSA key pair
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally with secure permissions
resource "local_file" "private_key" {
  filename        = "${path.module}/ec2_key.pem"
  content         = tls_private_key.ec2_key.private_key_pem
  file_permission = "0600"  # Owner read/write only
}

# Upload the public key to AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "ec2-key-${sha256(tls_private_key.ec2_key.public_key_openssh)}" # Stable name based on key content
  public_key = tls_private_key.ec2_key.public_key_openssh
}

# Output the private key (sensitive)
output "private_key" {
  value     = tls_private_key.ec2_key.private_key_pem
  sensitive = true
}

# Output the key name for reference
output "key_name" {
  value = aws_key_pair.generated_key.key_name
}
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.apache.public_ip
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.allow_traffic_apache.id
  network_interface_id = aws_instance.apache.primary_network_interface_id
}


resource "aws_security_group" "allow_traffic_apache" {
  name        = "allow_web_service"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc-main.id

  tags = {
    Name = "allow_webservice"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_webservice443_ipv4" {
  security_group_id = aws_security_group.allow_traffic_apache.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_webservice80_ipv4" {
  security_group_id = aws_security_group.allow_traffic_apache.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_webservice22_ipv4" {
  security_group_id = aws_security_group.allow_traffic_apache.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_traffic_apache.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
/*
data "aws_ami" "image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}*/

resource "aws_instance" "apache" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pub-sub.id
  key_name      = aws_key_pair.generated_key.key_name
  tags = {
    Name = "apache_machine"
  }
}


resource "aws_route_table_association" "A" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.RTable.id
}

resource "aws_route_table" "RTable" {
  vpc_id = aws_vpc.vpc-main.id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "routing_table"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc-main.id

  tags = {
    Name = "gateway_main"
  }
}

resource "aws_subnet" "pub-sub" {
  vpc_id     = aws_vpc.vpc-main.id     //require
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}


resource "aws_vpc" "vpc-main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "VPC-aswaniti"
    }
  
}

resource "aws_vpc" "vpc-main2" {
    cidr_block = "10.2.0.0/16"
    tags = {
        Name = "VPC-aswaniti1"
    }
  
}

