terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "ocp_network" {
  name      = "ocp-net"
  mode      = "nat"
  domain    = "ocp.local"
  addresses = ["192.168.122.0/24"]
  dhcp {
    enabled = true
  }
  xml = file("network.xml")
  }
}

# Base volume for master nodes
resource "libvirt_volume" "master_base" {
  name   = "master-base"
  source = "/var/lib/libvirt/images/ocp_discovery.iso"
  format = "qcow2"
}

# Master nodes
resource "libvirt_domain" "master" {
  count  = 3
  name   = "master-${count.index}"
  vcpu   = 4
  memory = 16384

  disk {
    volume_id = libvirt_volume.master_base.id
  }

  network_interface {
    network_id     = libvirt_network.ocp_network.id
    mac            = "52:54:00:12:34:1${count.index}"
    wait_for_lease = true
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }
}

# Base volume for worker nodes
resource "libvirt_volume" "worker_base" {
  name   = "worker-base"
  source = "/var/lib/libvirt/images/ocp_discovery.iso"
  format = "qcow2"
}

# Worker nodes
resource "libvirt_domain" "worker" {
  count  = 2
  name   = "worker-${count.index}"
  vcpu   = 2
  memory = 8192

  disk {
    volume_id = libvirt_volume.worker_base.id
  }

  network_interface {
    network_id     = libvirt_network.ocp_network.id
    mac            = "52:54:00:12:34:2${count.index}"
    wait_for_lease = true
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }
}
