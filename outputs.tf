output "db_name" {
  value = module.database.db_name
}

output "db_user" {
  value = module.database.db_user
}

output "backend_url" {
  value = "http://localhost:${var.backend_port}"
}

output "env_file_path" {
  value = module.app_config.env_file_path
}