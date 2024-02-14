###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}




variable "hdd_type" {
  type = string
  default = "network-hdd"
}
variable "os_image" {
  type = string
  default = "ubuntu-2004-lts"
}
variable "zone" {
  type = string
  default = "ru-central1-b"
}
variable "nat" {
  type = object({
    name = string,
    sub_name = string,
    sub_zone = string,
  })
  default = {
    name = "ng-nat"
    sub_name = "ng-sub"
    sub_zone = "ru-central1-b"
  }
}
variable "vm_web" {
  type = object({
    count = number,
    name = string,
    platform_id = string,
  })
  default = {
    count = 2
    name = "web"
    platform_id = "standard-v1"
  }
}
variable "vm_storage" {
  type = object({
    count = number,
    name = string,
    platform_id = string,
  })
  default = {
    count = 1
    name = "storage"
    platform_id = "standard-v1"
  }
}