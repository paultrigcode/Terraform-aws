terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.39.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

variable "instance_type" {
  type = string
  #default = "t2_micro"
}

variable "ami" {
  type = string
}

locals {
  project_name = "MyServer"
}

resource "aws_instance" "my_server" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "Another ${local.project_name}"
  }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}

#running terraform plan using var args terraform plan -var=instance_type="t2_micro"