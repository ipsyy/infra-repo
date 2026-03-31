terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "backend_env" {
  filename        = "${var.app_repo_path}/backend/.env"
  file_permission = "0600"

  content = <<-ENV
    ENVIRONMENT=${var.environment}
    DB_HOST=${var.db_host}
    DB_PORT=${var.db_port}
    DB_NAME=${var.db_name}
    DB_USER=${var.db_user}
    DB_PASSWORD=${var.db_password}
    BACKEND_PORT=${var.backend_port}
  ENV
}