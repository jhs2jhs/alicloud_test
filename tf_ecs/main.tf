
# Configure the Alicloud Provider
provider "alicloud" {
  version = ">= 1.5.3" # by default, it only used v1.0 or v0.6
  # using environment variables as access credentials
  region = "us-west-1"
}



resource "alicloud_security_group" "tf_sg" {
  name = "tf_sg_task1_jianhuashao"
  description = "security_group_task1_jianhuashao"
}

resource "alicloud_security_group_rule" "allow_http_80" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "${var.nic_type}"
  policy = "accept"
  port_range = "80/80"
  priority = 1
  security_group_id = "${alicloud_security_group.tf_sg.id}"
  cidr_ip = "0.0.0.0/0"
}


resource "alicloud_security_group_rule" "allow_https_443" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "${var.nic_type}"
  policy = "accept"
  port_range = "443/443"
  priority = 1
  security_group_id = "${alicloud_security_group.tf_sg.id}"
  cidr_ip = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_https_8888" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "${var.nic_type}"
  policy = "accept"
  port_range = "8888/8888"
  priority = 1
  security_group_id = "${alicloud_security_group.tf_sg.id}"
  cidr_ip = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "ssh-in" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "${var.nic_type}"
  policy = "accept"
  port_range = "22/22"
  priority = 1
  security_group_id = "${alicloud_security_group.tf_sg.id}"
  cidr_ip = "0.0.0.0/0"
}




# Create a web server
resource "alicloud_instance" "ecs_ianhuashao_task1" {

  provider          = "alicloud"
  availability_zone = "us-west-1a"

  instance_name        = "jianhuashao-task1"

  tags {
    name = "jianhuashao_task1"
    task_description = "Deploy one web app with 2 services, and use nginx or haproxy to load balance."
    alicloud_service = "ecs + rds"
    location = "us_west_1"
    env = "test"
  }

  image_id          = "ubuntu_16_0402_64_20G_alibase_20171227.vhd" 
  instance_type        = "ecs.sn2.medium" #"ecs.sn2ne.large" #"ecs.i1.xlarge"
  system_disk_category = "cloud_efficiency"

  internet_charge_type  = "PayByTraffic"
  internet_max_bandwidth_out = "${var.internet_max_bandwidth_out}"
  #allocate_public_ip = "${var.allocate_public_ip}" ## despached
  security_groups      = ["${alicloud_security_group.tf_sg.*.id}"]

  password = "${var.ecs_password}"
  is_outdated = true # have no time to find out the latest validate image_ids

  user_data = "${file("userdata.sh")}"
}

