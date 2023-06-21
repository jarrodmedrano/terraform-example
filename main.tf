terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = "us-east-2"
  access_key = var.TF_VAR_AWS_ACCESS_KEY_ID
  secret_key = var.TF_VAR_AWS_SECRET_ACCESS_KEY
}

data "aws_ami" "latest_amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = "Main VPC"
  }
}

resource "aws_instance" "server" {
  ami           = var.amis[var.aws_region]
  instance_type = "t2.micro"

  tags = {
    "Name" = "Server"
  }
}

resource "aws_subnet" "web" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet
  availability_zone = var.azs[0]
  tags = {
    "Name" = "Web Subnet"
  }
}

resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.main_vpc_name} IGW"
  }
}

resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    // all routes not explicitly known by the VPC will go through the internet gateway
    gateway_id = aws_internet_gateway.my_web_igw.id
    // gateway id that will handle the traffic ^ points to the internet gateway
  }
  tags = {
    "Name" = "my-default-rt"
  }
}

resource "aws_default_security_group" "default_sec_group" {
  vpc_id = aws_vpc.main.id
  //permit incoming traffic to ssh and http
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    // allows any ip address
    # cidr_blocks = [var.my_public_ip]
    // allows only my ip address
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    // allow all outbound traffic
    from_port = var.egress_dsg["from_port"]
    to_port   = var.egress_dsg["to_port"]
    protocol  = var.egress_dsg["protocol"]
    // any protocol
    cidr_blocks = var.egress_dsg["cidr_blocks"]
  }

  tags = {
    "Name" = "my-default-sg"
  }
}

// create ssh keypair for ec2 instance
resource "aws_key_pair" "terraform_ssh_key" {
  key_name   = "terraform_key_rsa"
  public_key = file("~/.ssh/aws/terraform_key_rsa.pub")
}

data "template_file" "user_data" {
  template = file("./web-app-template.yml")
  vars = {
    MY_SSH_KEY = "${aws_key_pair.terraform_ssh_key.key_name}"
  }
}

resource "aws_instance" "my_vm" {
  ami           = data.aws_ami.latest_amazon_linux2.id
  instance_type = var.my_instance[0]
  // cpu not supported in t2 micro
  # cpu_core_count              = var.my_instance[1]
  associate_public_ip_address = var.my_instance[2]
  subnet_id                   = aws_subnet.web.id
  vpc_security_group_ids      = [aws_default_security_group.default_sec_group.id]
  # key_name                    = "terraform_key_rsa.pub"
  key_name = aws_key_pair.terraform_ssh_key.key_name
  # user_data = file("entry_script.sh")
  user_data = data.template_file.user_data.rendered

  tags = {
    "Name" = "My EC2 Instance - Amazon Linux 2"
  }
}

# resource "aws_iam_user" "test" {
#   name = "x-user"
#   path = "/system/"
# }

# variable "users" {
#   type    = list(string)
#   default = ["demo-user", "admin1", "john"]
# }

# resource "aws_iam_user" "test" {
#   count = length(var.users)
#   name  = element(var.users, count.index)
#   path  = "/system/"
# }

# resource "aws_iam_user" "test" {
#   name = "x-user${count.index}}"
#   path = "/system/"
#   count = 3
# }