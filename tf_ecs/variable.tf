variable "ecs_password" {
  default = "Test12345"
}

variable "nic_type" {
  #default = "internet"
  default = "intranet"
}

variable "internet_max_bandwidth_out" {
  default = 5
}

variable "allocate_public_ip" {
  default = true
}




