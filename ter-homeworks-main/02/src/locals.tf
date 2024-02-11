locals {
  vm_name_default = "netology-develop-platform"
  vm_name_web = "${local.vm_name_default}-web"
  vm_name_db = "${local.vm_name_default}-db"
  metadata = {
    serial-port-enable = true,
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}