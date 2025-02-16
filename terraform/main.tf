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
  domain    = "gcp.lab.cloud"
  addresses = ["192.168.100.0/24"]
}


# Create a base volume for the ISO image
resource "libvirt_volume" "ocp_discovery_iso" {
  name = "ocp-discovery-iso"
  pool = "default"
  source = "/var/lib/libvirt/images/ocp_discovery.iso"
  format = "raw"
}

# Create a base volume for the master VMs (100GB)
resource "libvirt_volume" "master_disk" {
  name           = "master-${count.index}"
  pool           = "default"
  size           = 100 * 1024 * 1024 * 1024 # 100GB in bytes
  format         = "qcow2"
  count          = 3
}

# Create a base volume for the worker VMs (100GB)
resource "libvirt_volume" "worker_disk" {
  name           = "worker-${count.index}"
  pool           = "default"
  size           = 100 * 1024 * 1024 * 1024 # 100GB in bytes
  format         = "qcow2"
  count          = 2
}

# Master nodes
resource "libvirt_domain" "master" {
  count  = 3
  name   = "master-${count.index}"
  vcpu   = 4
  memory = 16384

  disk {
    volume_id = element(libvirt_volume.master_disk.*.id, count.index)
  }

  disk {
    file = libvirt_volume.ocp_discovery_iso.source
  }

  network_interface {
    network_id     = libvirt_network.ocp_network.id
    mac            = "52:54:00:12:34:1${count.index}"
    addresses      = ["192.168.100.1${count.index}"]
    hostname       = "master-${count.index}"
    wait_for_lease = true
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }
}

# Worker nodes
resource "libvirt_domain" "worker" {
  count  = 2
  name   = "worker-${count.index}"
  vcpu   = 2
  memory = 8192

  disk {
    volume_id = element(libvirt_volume.worker_disk.*.id, count.index)
  }

  disk {
    file = libvirt_volume.ocp_discovery_iso.source
  }

  network_interface {
    network_id     = libvirt_network.ocp_network.id
    mac            = "52:54:00:12:34:2${count.index}"
    addresses      = ["192.168.100.2${count.index}"]
    hostname       = "worker-${count.index}"    
    wait_for_lease = true
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }
}
