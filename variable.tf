variable "proxmox_endpoint" {
  type = string
  default = "https://my-proxmox-endpoint.local/"
}

variable "proxmox_username" {
  type = string
  default = "root@pam"
}

variable "proxmox_password" {
  type = string
  default = "my-proxmox-password"
}

variable "gateway" {
    type = string
    default = "192.168.254.254"
    description = "network gateway"
}

variable "container_ips" {
    type = string
    default = "192.168.254.215"
}

variable "network_range" {
    type = string
    default = "24"
}

variable "private_key_filename" {
    type = string
    default = "my-private-key.pem" 
}

variable "node_name" {
    type = string
    default = "pve01"
}

variable "vm_id" {
    type = string
    default = "1005"
}