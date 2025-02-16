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
    network_name     = "default"
    addresses      = ["192.168.122.1${count.index}"]
    hostname       = "master-${count.index}"
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }

# Enable VNC console
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  # Set CPU mode to host-passthrough
  cpu {
    mode = "host-passthrough"
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
    network_name     = "default"
    addresses      = ["192.168.122.2${count.index}"]
    hostname       = "worker-${count.index}"
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }

# Enable VNC console
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  # Set CPU mode to host-passthrough
  cpu {
    mode = "host-passthrough"
  }

}
