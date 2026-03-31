terraform {
  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0"
    }
  }
}

resource "mysql_database" "app" {
  name                  = var.db_name
  default_character_set = "utf8mb4"
  default_collation     = "utf8mb4_unicode_ci"
}

resource "mysql_user" "app" {
  user               = var.db_user
  host               = "localhost"
  plaintext_password = var.db_password
}

resource "mysql_grant" "app" {
  user       = mysql_user.app.user
  host       = mysql_user.app.host
  database   = mysql_database.app.name
  privileges = ["ALL"]
}