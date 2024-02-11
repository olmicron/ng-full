# Создаём файл ansible-inventory.cfg со список серверов
resource "local_file" "ansible_inventory" {
  content  = templatefile(
    "${path.module}/ansible-inventory.tftpl",
    {
      vm_web      = yandex_compute_instance.vm_web,
      vm_db       = yandex_compute_instance.vm_db,
      vm_storage  = [yandex_compute_instance.storage]
    }
  )
  filename = "./ansible-inventory.cfg"
}