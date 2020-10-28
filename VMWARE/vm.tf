provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphereDatacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphereDatastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vsphereDvs
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "pg1" {
  name          = var.vspherePg1
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "pg2" {
  name          = var.vspherePg2
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphereCluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphereVmTemplate
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  pgmap = {
    "vm1" = data.vsphere_network.pg1.id
    "vm2" = data.vsphere_network.pg2.id
  }
  ipmap = {
    "vm1" = "1.1.1.100"
    "vm2" = "1.1.2.100"
  }
  gatewaymap = {
    "gw1" = "1.1.1.1"
    "gw2" = "1.1.2.1"
  }
  natmap = {
    "vm1" = var.vm1NatIp
    "vm2" = var.vm2NatIp
  }
  domain    = "ospeg2.cisco.com"
  prefixlen = "24"
}

resource "vsphere_virtual_machine" "vm" {
  count            = 2
  name             = "${var.vmPrefix}${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 1024
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = local.pgmap["vm${count.index + 1}"]
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  provisioner "file" {
    source      = "app.py"
    destination = "/home/cisco/app.py"
    connection {
      host     = local.natmap["vm${count.index + 1}"]
      type     = "ssh"
      user     = "cisco"
      password = "cisco"
    }
  }
  provisioner "file" {
    source      = "acilogo.jpg"
    destination = "/home/cisco/acilogo.jpg"
    connection {
      host     = local.natmap["vm${count.index + 1}"]
      type     = "ssh"
      user     = "cisco"
      password = "cisco"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/cisco/static",
      "mv /home/cisco/acilogo.jpg /home/cisco/static/",
      "echo ${var.rootPwd} | sudo -E -S yum -y install python3-pip",
      "echo ${var.rootPwd} | sudo pip3 install flask --proxy proxy.esl.cisco.com:80 --trusted-host pypi.python.org",
      "echo ${var.rootPwd} | sudo systemctl stop firewalld",
      "echo 'python3 /home/cisco/app.py 2>&1 &' > /home/cisco/start_app.sh",
      "chmod u+x /home/cisco/start_app.sh",
      "sleep 5",
      "/home/cisco/start_app.sh"
    ]
    connection {
      host     = local.natmap["vm${count.index + 1}"]
      type     = "ssh"
      user     = "cisco"
      password = "cisco"
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${var.vmPrefix}${count.index + 1}"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = local.ipmap["vm${count.index + 1}"]
        ipv4_netmask = local.prefixlen
      }

      ipv4_gateway    = local.gatewaymap["gw${count.index + 1}"]
      dns_server_list = var.dnsServers
    }
  }
}

