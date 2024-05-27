output "master_internal_ipv4" {
  value = yandex_compute_instance.master.network_interface[0].ip_address
}

output "node1_internal_ipv4" {
  value = yandex_compute_instance.node1.network_interface[0].ip_address
}

output "node2_internal_ipv4" {
  value = yandex_compute_instance.node2.network_interface[0].ip_address
}

output "kms_key_id" {
  value = yandex_kms_symmetric_key.key-a.id
}


output "master_public_ipv4" {
  value = yandex_compute_instance.master.network_interface[0].nat_ip_address
}

output "node1_public_ipv4" {
  value = yandex_compute_instance.node1.network_interface[0].nat_ip_address
}

output "node2_public_ipv4" {
  value = yandex_compute_instance.node2.network_interface[0].nat_ip_address
}