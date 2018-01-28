variable "engine" {
  default = "MySQL"
}
variable "engine_version" {
  default = "5.7"
}
variable "instance_class" {
  default = "rds.mysql.t1.small"
}
variable "storage" {
  default = "5"
}
variable "net_type" {
  default = "Intranet"
}

variable "user_name" {
  default = "jian"
}
variable "password" {
  default = "Test12345"
}

variable "database_name" {
  default = "db_test"
}
variable "database_character" {
  default = "utf8"
}
variable "zone_id" {
  default = "us-west-1a"
}