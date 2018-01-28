resource "alicloud_db_instance" "instance" {
  zone_id = "${var.zone_id}"
  engine = "${var.engine}"
  engine_version = "${var.engine_version}"
  instance_type = "${var.instance_class}"
  instance_storage = "${var.storage}"
}


resource "alicloud_db_account" "account" {
  instance_id = "${alicloud_db_instance.instance.id}"
  name = "${var.user_name}"
  password = "${var.password}"
}

resource "alicloud_db_connection" "connection" {
  instance_id = "${alicloud_db_instance.instance.id}"
  connection_prefix = "terraform"
}

resource "alicloud_db_database" "db" {
  instance_id = "${alicloud_db_instance.instance.id}"
  name = "${var.database_name}"
  character_set = "${var.database_character}"
}

resource "alicloud_db_account_privilege" "privilege" {
  instance_id = "${alicloud_db_instance.instance.id}"
  account_name = "${alicloud_db_account.account.name}"
  db_names = ["${alicloud_db_database.db.name}"]
  privilege = "ReadWrite"
}