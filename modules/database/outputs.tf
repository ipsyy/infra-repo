output "db_name" {
  value = mysql_database.app.name
}

output "db_user" {
  value = mysql_user.app.user
}