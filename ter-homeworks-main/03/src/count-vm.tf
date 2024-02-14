
# Создаем облачную сеть
resource "yandex_vpc_network" "ng_nat" {
  name = local.config.nat.name
}

# Создаем подсеть в сети выше
resource "yandex_vpc_subnet" "ng_sub_1" {
  name           = "${local.config.nat.sub_name}-1"
  zone           = local.config.nat.sub_zone
  network_id     = yandex_vpc_network.ng_nat.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# Указываем образ ОС для ВМ
data "yandex_compute_image" "ubuntu" {
  family = local.config.os.image
}

# Создаем 2 одинаковые ВМ
resource "yandex_compute_instance" "vm_web" {
  count = local.config.vm.web.count

  depends_on = [
    yandex_compute_instance.vm_db
  ]

  name        = "${local.config.vm.web.name}-${count.index+1}"
  platform_id = local.config.vm.web.platform_id

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

  metadata = local.metadata

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.example.id
    ]
  }
}