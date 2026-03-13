##############################################
# Provider
##############################################
provider "openstack" {
  auth_url    = var.os_auth_url
  tenant_name = var.os_tenant
  user_name   = var.os_username
  password    = var.os_password
  region      = var.os_region
}

##############################################
# Network + Subnet
##############################################
resource "openstack_networking_network_v2" "example_net" {
  name = "example-net"
}

resource "openstack_networking_subnet_v2" "example_subnet" {
  name       = "example-subnet"
  network_id = openstack_networking_network_v2.example_net.id
  cidr       = "192.168.50.0/24"
  ip_version = 4
  gateway_ip = "192.168.50.1"
}

##############################################
# Security Group
##############################################
resource "openstack_networking_secgroup_v2" "example_sg" {
  name        = "example-security-group"
  description = "Allow SSH, HTTP, HTTPS"
}

# SSH (22)
resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  security_group_id = openstack_networking_secgroup_v2.example_sg.id
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

# HTTP (80)
resource "openstack_networking_secgroup_rule_v2" "http_rule" {
  security_group_id = openstack_networking_secgroup_v2.example_sg.id
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

# HTTPS (443)
resource "openstack_networking_secgroup_rule_v2" "https_rule" {
  security_group_id = openstack_networking_secgroup_v2.example_sg.id
  direction         = "ingress"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
}

##############################################
# Port (Attach Network + Security Group)
##############################################
resource "openstack_networking_port_v2" "vm_port" {
  name               = "vm-port"
  network_id         = openstack_networking_network_v2.example_net.id
  security_group_ids = [openstack_networking_secgroup_v2.example_sg.id]
}

##############################################
# VM Instance
##############################################
resource "openstack_compute_instance_v2" "vm" {
  name            = "example-vm"
  flavor_name     = var.vm_flavor
  image_name      = var.vm_image
  key_pair        = var.keypair

  network {
    port = openstack_networking_port_v2.vm_port.id
  }
}
