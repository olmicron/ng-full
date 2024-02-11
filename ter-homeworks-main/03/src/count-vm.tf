
# Создаем облачную сеть
resource "yandex_vpc_network" "ng_nat" {
  name = "ng-nat"
}

# Создаем подсеть в сети выше
resource "yandex_vpc_subnet" "ng_sub_1" {
  name           = "ng-nat-sub-1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.ng_nat.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# Указываем образ ОС для ВМ
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

# Создаем 2 одинаковые ВМ
resource "yandex_compute_instance" "vm_web" {
  count = 2

  depends_on = [
    yandex_compute_instance.vm_db
  ]

  name        = "web-${count.index+1}"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = "network-hdd"
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