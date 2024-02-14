locals {
  ssh_key = file("key.pub")
  metadata = {
    serial-port-enable = true,
    ssh-keys           = sensitive("ubuntu:${local.ssh_key}")
  }
  config = {
    global = {
      hdd_type = "network-hdd"
    }
    os = {
      image = "ubuntu-2004-lts"
    }
    nat = {
      name = "ng-nat"
      sub_name = "ng-sub-1"
      sub_zone = "ru-central1-b"
    }
    vm = {
      web = {
        count = 2
        name = "web"
        platform_id = "standard-v1"
      },
      db = var.list_vm_db,
      storage = {
        count = 1
        name = "storage"
        platform_id = "standard-v1"
      },
    }
  }
}