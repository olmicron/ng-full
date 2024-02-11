output "vm" {
  value = <<-EOT
vm1 (web):
instance_name = ${yandex_compute_instance.platform.name}
external_ip   = ${yandex_compute_instance.platform.network_interface.0.nat_ip_address}
fqdn          = ${yandex_compute_instance.platform.fqdn}

vm2 (db):
instance_name = ${yandex_compute_instance.vm_db.name}
external_ip   = ${yandex_compute_instance.vm_db.network_interface.0.nat_ip_address}
fqdn          = ${yandex_compute_instance.vm_db.fqdn}
EOT
}