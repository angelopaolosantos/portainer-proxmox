resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" {
    command = "mkdir -p .ssh"
  }

  provisioner "local-exec" { # Copy a "myKey.pem" to local computer.
    command = "echo '${tls_private_key.private_key.private_key_pem}' | tee ${path.cwd}/.ssh/${var.private_key_filename}"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${path.cwd}/.ssh/${var.private_key_filename}"
  }
}

resource "proxmox_virtual_environment_container" "portainer_container" {
  description = "Managed by Terraform"
  node_name = var.node_name
  vm_id     = var.vm_id
  tags        = ["terraform", "ubuntu"]

  initialization {
    hostname = "ubuntu-portainer"

    ip_config {
      ipv4 {
        address = "${var.container_ips}/${var.network_range}"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.private_key.public_key_openssh)]
      # password = random_password.vm_password.result
      password = "mypassword"
    }
  }

  network_interface {
    name = "veth0"
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.portainer_ubuntu_24_04_standard_img.id
    type             = "ubuntu"
  }

  disk {
    datastore_id = "local-zfs"
    size = 25
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  features {
    nesting = true
    fuse = true
  }

  unprivileged = true
}

resource "proxmox_virtual_environment_download_file" "portainer_ubuntu_24_04_standard_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "pve01"
  file_name = "portainer-ubuntu-24.04-standard.tar.zst"
  url          = "http://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

resource "random_password" "container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

# Ansible Section 

resource "ansible_host" "portainer" {
  name   = var.container_ips

  variables = {
    # Set user and private key for Ansible ssh connection 
    ansible_user                 = "root" # proxmox lxc container adds ssh keys into root user account
    ansible_ssh_private_key_file = "./.ssh/${var.private_key_filename}"
    ansible_python_interpreter   = "/usr/bin/python3"
    
    host_name                    = "ubuntu-portainer"
    greetings                    = "from host!"
    some                         = "variable"
    private_ip                   = var.container_ips
  }

}

# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_file_new" {
  content = <<-DOC
    # Ansible vars_file containing variable values from Terraform.
    # Generated by Terraform mgmt configuration.

    # tf_variable_1: "sample value 1"
    # tf_variable_2: 2
    DOC
  filename = "./ansible/tf_ansible_vars_file.yaml"
}