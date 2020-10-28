provider "aci" {
  username = "ansible"
  private_key = "./ansible.key"
  cert_name = "ansible"
  insecure = true
  url = "https://10.48.168.3"
}

resource "null_resource" "iterator" {
  count = 5
}

resource "aci_tenant" "demo" {
  name = "${var.tenantName}-${null_resource.iterator}"
  description = "created by terraform"
}

resource "aci_vrf" "vrf1" {
  tenant_dn = "${aci_tenant.demo[null_resource.iterator].id}"
  name      = "vrf1"
}

resource "aci_bridge_domain" "bd1" {
  tenant_dn          = "${aci_tenant.demo[null_resource.iterator].id}"
  relation_fv_rs_ctx = "${aci_vrf.vrf1[null_resource.iterator].name}"
  name               = "bd1"
}

