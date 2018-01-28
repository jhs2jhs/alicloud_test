

output "public_id" {
  value = "${alicloud_instance.ecs_ianhuashao_task1.public_ip}"
}
output "private_id" {
  value = "${alicloud_instance.ecs_ianhuashao_task1.private_ip}"
}
