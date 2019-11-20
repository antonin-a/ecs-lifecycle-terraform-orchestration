# ECS Instance Module

terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    bucket = "obs-terraform-backend"
    key    = "ecs-p2-terraform-plan--boot-from-volumes"
    region = "eu-west-0"
    endpoint = "https://oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

/*resource "flexibleengine_compute_instance_v2" "instance-from-image" {
  availability_zone = var.availability_zone
  //If there is no existing system EVS provided (.tfvars system_disks), set count to instance_count value. Else, do not create this ressource (count=0)
  count             = length(var.system_disks) == 0 ? var.instance_count : 0
  name              = var.instance_count > 1 ? format("%s-%d", var.instance_name, count.index + 1) : var.instance_name
  flavor_name       = var.flavor_name
  key_pair          = var.key_pair
  user_data         = var.user_data

  block_device {
    //Block device based on an existing IMS image
    uuid                  = var.image_id
    source_type           = "image"
    volume_size           = 70
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
    volume_type           = "SATA"
  }

  block_device {
    //Block device based on existing data EVS provided on .tfvars data_disks
    uuid                  = var.data_disks[count.index]
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 1
    delete_on_termination = false
  }

  //If using ECS with local storage, remember to add another block device as documented here : https://www.terraform.io/docs/providers/flexibleengine/r/compute_instance_v2.html#instance-with-multiple-ephemeral-disks

  network {
    port           = flexibleengine_networking_port_v2.instance_port[count.index].id
    access_network = true
  }
}*/

resource "flexibleengine_compute_instance_v2" "instance" {
  availability_zone = var.availability_zone
  count             = length(var.system_disks) > 0 ? length(var.system_disks) : 0
  name              = length(var.system_disks) > 1 ? format("%s-%d", var.instance_name, count.index + 1) : var.instance_name
  flavor_name       = var.flavor_name
  key_pair          = var.key_pair
  user_data         = var.user_data

  block_device {
    uuid                  = var.system_disks[count.index]
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = false
  }

  block_device {
    uuid                  = var.data_disks[count.index]
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 1
    delete_on_termination = false
  }

  network {
    port           = flexibleengine_networking_port_v2.instance_port[count.index].id
    access_network = true
  }
}

resource "flexibleengine_networking_port_v2" "instance_port" {
  network_id         = var.network_id
  count              = length(var.system_disks)
  security_group_ids = var.security_groups
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = var.subnet_id
  }
}

resource "flexibleengine_networking_floatingip_v2" "fip" {
  count = var.attach_eip ? length(var.system_disks) : 0
  pool  = var.ext_net_name
  port_id = element(
    flexibleengine_networking_port_v2.instance_port.*.id,
    count.index,
  )
  depends_on = [flexibleengine_compute_instance_v2.instance]
}
