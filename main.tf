terraform {
  required_version = ">= 1.5.0"

  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "mysql" {
  endpoint = "${var.mysql_host}:${var.mysql_port}"
  username = var.mysql_root_user
  password = var.mysql_root_password
}

provider "local" {}

module "database" {
  source      = "./modules/database"
  environment = var.environment
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
}

module "app_config" {
  source        = "./modules/app-config"
  environment   = var.environment
  db_host       = var.mysql_host
  db_port       = var.mysql_port
  db_name       = module.database.db_name
  db_user       = module.database.db_user
  db_password   = var.db_password
  backend_port  = var.backend_port
  app_repo_path = var.app_repo_path

  depends_on = [module.database]
}