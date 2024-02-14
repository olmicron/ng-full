
# Создаем подсеть в сети выше
resource "yandex_vpc_subnet" "ng_sub_2" {
  name           = "${var.nat.sub_name}-2"
  zone           = var.nat.sub_zone
  network_id     = yandex_vpc_network.ng_nat.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

# Создаем Х одинаковых ВМ (в соответствии со списком)
resource "yandex_compute_instance" "vm_db" {
  for_each = var.vm_db

  name        = each.value.vm_name
  platform_id = each.value.platform_id
  zone        = yandex_vpc_subnet.ng_sub_2.zone

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = each.value.disk_type
      size     = each.value.disk_size
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

  allow_stopping_for_update = false
}





# Список ВМ с параметрами
# Неопределенные данные (типо yandex_vpc_subnet и т.п.) нельзя использовать в переменных :(
variable "vm_db" {
  type = map(object({
    vm_name       = string,
    platform_id   = string,
    cores         = number,
    memory        = number,
    core_fraction = number,
    disk_type     = string,
    disk_size     = number,
    //disk_image_id = optional(string)
    //subnet_id     = string,
  }))
  default = {
    main = {
      vm_name       = "main",
      platform_id   = "standard-v1",
      cores         = 2,
      memory        = 2,
      core_fraction = 20,
      disk_type     = "network-hdd",
      disk_size     = 5,
      //disk_image_id = data.yandex_compute_image.ubuntu.image_id
      //subnet_id     = yandex_vpc_subnet.ng_sub_2.id,
    },
    replica = {
      vm_name       = "replica",
      platform_id   = "standard-v1",
      cores         = 2,
      memory        = 1,
      core_fraction = 20,
      disk_type     = "network-hdd",
      disk_size     = 5,
      //disk_image_id = data.yandex_compute_image.ubuntu.image_id
      //subnet_id     = yandex_vpc_subnet.ng_sub_2.id,
    }
  }
}