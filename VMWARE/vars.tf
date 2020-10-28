variable "vsphere_user" {
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
}

variable "vsphere_server" {
  default = "10.48.168.200"
}

variable "ssh_user" {
  default = "cisco"
}

variable "ssh_password" {
  default = "cisco"
}

variable "dnsServers" {
  type    = list(string)
  default = ["10.48.168.15"]
}

variable "vmPrefix" {
  default = "terraform-demo"
}



variable vsphereDvs {
  default = "vc7"
}

variable "vsphereVmTemplate" {
  default = "centos-tpl"
}

variable "vsphereDatastore" {
  default = "extra003"
}

variable "vsphereDatacenter" {
  default = "QA"
}

variable "vsphereCluster" {
  default = "clusterOne"
}

variable "vspherePg1" {
  default = "pvtoctober|app1|epg1"
}


variable "vspherePg2" {
  default = "pvtoctober|app1|epg2"
}

variable "vm1NatIp" {
  default = "10.48.168.190"
}

variable "vm2NatIp" {
  default = "10.48.168.191"
}

variable "rootPwd" {
  default = "cisco"
}

variable "domainName" {
  default = "ospeg2.cisco.com"
}
