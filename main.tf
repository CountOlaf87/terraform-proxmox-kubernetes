terraform {
    required_providers {
      proxmox = {
        source = "telmate/proxmox"
        version = "2.9.0"
      }
    }
}

provider "proxmox" {
  pm_timeout = 600
  pm_parallel = 1
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = var.proxmox_api
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = var.proxmox_token_id
  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = var.proxmox_token_secret
  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
#   pm_debug      = true
#   pm_log_levels = {
#     _default    = "debug"
#     _capturelog = ""
#   }
}
# resource is formatted to be "[type]" "[entity_name]" so in this case
# we are looking to create a proxmox_vm_qemu entity named test_server
resource "proxmox_vm_qemu" "kube-server" {
  clone_wait = 30
  ci_wait = 30
  count = 1
  name = "kube-server-0${count.index + 1}"
  target_node = var.proxmox_host
  # thanks to Brian on YouTube for the vmid tip
  # http://www.youtube.com/channel/UCTbqi6o_0lwdekcp-D6xmWw
  vmid = "20${count.index + 1}"
  clone = var.proxmox_template
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "10G"
    type = "scsi"
    storage = var.proxmox_storage
    #storage_type = "zfspool"
    iothread = 1
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  
  network {
    model = "virtio"
    bridge = "vmbr17"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  ipconfig0 = "ip=10.10.2.8${count.index + 1}/24,gw=10.10.2.2"
  ipconfig1 = "ip=10.17.0.4${count.index + 1}/24"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
#   timeouts {
#     create = "2m"
#     delete = "2m"
#   }
}
resource "proxmox_vm_qemu" "kube-agent" {
  clone_wait = 120
  ci_wait = 600
  count = 2
  name = "kube-agent-0${count.index + 1}"
  target_node = var.proxmox_host
  vmid = "30${count.index + 1}"
  clone = var.proxmox_template
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "10G"
    type = "scsi"
    storage = var.proxmox_storage
    #storage_type = "zfspool"
    iothread = 1
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  
  network {
    model = "virtio"
    bridge = "vmbr17"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  ipconfig0 = "ip=10.10.2.9${count.index + 1}/24,gw=10.10.2.2"
  ipconfig1 = "ip=10.17.0.4${count.index + 1}/24"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
#   timeouts {
#     create = "2m"
#     delete = "2m"
#   }
}
resource "proxmox_vm_qemu" "kube-storage" {
  clone_wait = 120
  ci_wait = 600
  count = 1
  name = "kube-storage-0${count.index + 1}"
  target_node = var.proxmox_host
  vmid = "40${count.index + 1}"
  clone = var.proxmox_template
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "20G"
    type = "scsi"
    storage = var.proxmox_storage
    #storage_type = "zfspool"
    iothread = 1
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  
  network {
    model = "virtio"
    bridge = "vmbr17"
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  ipconfig0 = "ip=10.10.2.10${count.index + 1}/24,gw=10.10.2.2"
  ipconfig1 = "ip=10.17.0.4${count.index + 1}/24"
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
#   timeouts {
#     create = "2m"
#     delete = "2m"
#   }
}