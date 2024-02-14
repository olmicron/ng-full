locals {
  ssh_key = file("key.pub")
  metadata = {
    serial-port-enable = true,
    ssh-keys           = sensitive("ubuntu:${local.ssh_key}")
  }
}

