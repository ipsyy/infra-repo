terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform-aws.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

variable "environment" {
  type    = string
  default = "aws"
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "backend_port" {
  type    = number
  default = 8000
}

variable "ssh_public_key_path" {
  type = string
}

module "ec2" {
  source              = "./modules/ec2"
  environment         = var.environment
  aws_region          = var.aws_region
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  ssh_public_key_path = var.ssh_public_key_path
  db_name             = var.db_name
  db_user             = var.db_user
  db_password         = var.db_password
  backend_port        = var.backend_port
}

output "frontend_url" {
  value = "http://${module.ec2.ec2_public_ip}"
}

output "backend_url" {
  value = "http://${module.ec2.ec2_public_ip}:8000"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${module.ec2.ec2_public_ip}"
}