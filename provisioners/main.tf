terraform {
  backend "remote" {
    organization = "paultrig"

    workspaces {
      name = "provisioners"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.39.0"
    }
  }
}

provider "aws" {
  version = "~> 4.0"
  region  = "us-east-1"
}


data "aws_vpc" "main" {
  id = "vpc-086ebf9c2ac7bf7c5"
}

# resource "aws_subnet" "example" {
#   vpc_id            =  data.aws_vpc.main.id
#   availability_zone = "us-west-2a"
#   cidr_block        = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 1)
# }

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "My Server security group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 90
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["102.134.113.1/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false

    },
  ]

  egress {
    description      = "outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false

  }

}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7tn9j9mc78TS4SigR0Qd1c439HEBkZyZH1j3htpl5Tr0JcbHPuH9klZqfWQW1lB2pYHevlhnS0ga19VyZobZc4upaZU93K3WLp/quPpL/bxlLnjp7gFUVM3qic/IBBTHvMdZhNT1d4G8h5tHANFxx8n96T/M9QWzpo3vTKyLckqLwJniUC7qZY6kfCteg5YUxx5Yp2XTLD1BBX7F0Ex+x/VRzGud95YsltuCcWrmcaAm4I22VEGSMvmF+a7vobqHeP2vJnXheNWuVchsPKA2YFl2hRSlI7RLiJEtaB/2jVZ8QB0E6urhbCgho3qoTtBB2Cts0SCpwlsvEuD5zrMor ajakayepaul@Ajakayes-MBP.lan"
}


data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

resource "aws_instance" "my_server" {
  ami                    = "ami-09d3b3274b6c5d4aa"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data              = data.template_file.user_data.rendered
  tags = {
    Name = "MyServer"
  }
}
output "public_ip" {
  value = aws_instance.my_server.public_ip
}