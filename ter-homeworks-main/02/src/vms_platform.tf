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
  default     = "ru-central1-d"
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
  description = "VPC network & subnet name"
}
variable "vpc_name_db" {
  type        = string
  default     = "develop_db"
  description = "VPC network & subnet name"
}


variable "yandex_compute_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
}
/*variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
}*/
variable "vm_web_platform" {
  type        = string
  default     = "standard-v3"
}
/*variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
}*/
variable "vm_db_platform" {
  type        = string
  default     = "standard-v3"
}
variable "vm_db_zone" {
  type        = string
  default     = "ru-central1-b"
}
variable "vms_resources" {
  type        = map(any)
  default     = {
    web = {
       cores = 2,
       memory = 1,
       core_fraction = 20
    },
    db = {
       cores = 2,
       memory = 2,
       core_fraction = 20
    }
  }
}

###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-ed25519 *************"
  description = "ssh-keygen -t ed25519"
}
