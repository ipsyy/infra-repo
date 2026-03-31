variable "environment" {
  description = "Deployment environment (dev | prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "mysql_host" {
  type    = string
  default = "127.0.0.1"
}

variable "mysql_port" {
  type    = number
  default = 3306
}

variable "mysql_root_user" {
  type    = string
  default = "root"
}

variable "mysql_root_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_user" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "backend_port" {
  type    = number
  default = 8000
}

variable "app_repo_path" {
  description = "Absolute path to your app-repo on this machine e.g. /home/yourname/app-repo"
  type        = string
}