variable "tenantName" {
  default = "terraformDemo"
}
variable "aciUser" {
  default = "ansible"
}
variable "aciPrivateKey" { 
  default = "/home/cisco/ansible.key"
}
variable "aciCertName" {
  default = "ansible"
}
variable "aciUrl" {
  default = "https://10.48.168.3"
}

variable "bd_subnet" {
  type    = "string"
  default = "1.1.1.1/24"
}
variable "provider_profile_dn" {
  default = "uni/vmmp-VMware"
}
