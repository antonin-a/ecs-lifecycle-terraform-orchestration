# ECS Instance Module

terraform {
  required_version = ">= 0.12.0"
  //Uncomment if you want to use Object storage as bakcend for your .tfstate
  /*backend "s3" {
    bucket = "obs-terraform-backend"
    key    = "ecs-p2-terraform-plan--boot-from-volumes"
    region = "eu-west-0"
    endpoint = "https://oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    skip_region_validation      = true
    skip_credentials_validation = true
  }*/
}

// Instance ressource block
resource "flexibleengine_compute_instance_v2" "instance" {
  availability_zone = var.availability_zone
  count             = var.instance_count
  name              = var.instance_name
  flavor_name       = var.flavor_name
  key_pair          = var.key_pair
  user_data         = var.user_data

  block_device {
    uuid                  = var.instance.system_disk
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = false
  }

  block_device {
    uuid                  = var.instance.data_disk
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
  count              = var.instance_count
  security_group_ids = var.security_groups
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = var.fixed_ip
  }
}

resource "flexibleengine_networking_floatingip_v2" "fip" {
  count = var.attach_eip ? var.instance_count : 0
  pool  = var.ext_net_name
  port_id = element(
    flexibleengine_networking_port_v2.instance_port.*.id,
    count.index,
  )
  depends_on = [flexibleengine_compute_instance_v2.instance]
}
