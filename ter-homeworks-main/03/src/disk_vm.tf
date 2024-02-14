
# Создаем диски (3 HDD диска по 1 Гб каждый)
resource "yandex_compute_disk" "default" {
  count = 3
  name  = "disk-${count.index+1}"
  type  = local.config.global.hdd_type
  zone  = yandex_vpc_subnet.ng_sub_2.zone
  size  = 1
}


# Создаем ВМ и подключаем туда созданные выше диски
resource "yandex_compute_instance" "storage" {
  name        = local.config.vm.storage.name
  platform_id = local.config.vm.storage.platform_id
  zone        = yandex_vpc_subnet.ng_sub_2.zone

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = local.config.global.hdd_type
      size     = 5
    }
  }

  # Динамически подключаем диски
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.default
    content {
      disk_id = secondary_disk.value.id
    }
  }

  metadata = local.metadata

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.ng_sub_2.id
    nat       = true
  }
}