# Master VM
resource "yandex_compute_instance" "master" {
  name                      = local.instance_master
  hostname                  = local.instance_master
  zone                      = var.default_zone_a
  allow_stopping_for_update = true

  platform_id = "standard-v1"
  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.public_resources.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet["central1-a"].id
    nat        = true
    ip_address = "10.0.1.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "/home/ubuntu/.ssh/id_rsa"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = yandex_compute_instance.master.network_interface[0].nat_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_rsa"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = yandex_compute_instance.master.network_interface[0].nat_ip_address
    }
  }
}

module "instance" {
  source = "./modules/instance"
  cluster_size = var.cluster_size
}


resource "yandex_compute_instance" "nodes" {
  count = length(var.instance_names)

  name                      = local.instance_names[count.index]
  hostname                  = local.instance_names[count.index]
  zone                      = var.default_zones[count.index]
  allow_stopping_for_update = true

  platform_id = "standard-v2"
  resources {
    cores         = var.public_resources_node.cores
    memory        = var.public_resources_node.memory
    core_fraction = var.public_resources_node.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.public_resources_node.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet["central1-${var.zones[count.index]}"].id
    nat        = true
    ip_address = "10.0.${count.index + 2}.${count.index + 10}"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


# # Node1 VM
# resource "yandex_compute_instance" "node1" {
#   name                      = local.instance_node1
#   hostname                  = local.instance_node1
#   zone                      = var.default_zone_b
#   allow_stopping_for_update = true

#   platform_id = "standard-v2"
#   resources {
#     cores         = var.public_resources_node.cores
#     memory        = var.public_resources_node.memory
#     core_fraction = var.public_resources_node.core_fraction
#   }

#   boot_disk {
#     initialize_params {
#       image_id = var.public_image
#       size     = var.public_resources_node.size
#     }
#   }

#   scheduling_policy {
#     preemptible = true
#   }

#   network_interface {
#     subnet_id  = yandex_vpc_subnet.subnet["central1-b"].id
#     nat        = true
#     ip_address = "10.0.2.11"
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
#   }
# }
# # Node2 VM
# resource "yandex_compute_instance" "node2" {
#   name                      = local.instance_node2
#   hostname                  = local.instance_node2
#   zone                      = var.default_zone_d
#   allow_stopping_for_update = true

#   platform_id = "standard-v2"
#   resources {
#     cores         = var.public_resources_node.cores
#     memory        = var.public_resources_node.memory
#     core_fraction = var.public_resources_node.core_fraction
#   }

#   boot_disk {
#     initialize_params {
#       image_id = var.public_image
#       size     = var.public_resources_node.size
#     }
#   }

#   scheduling_policy {
#     preemptible = true
#   }

#   network_interface {
#     subnet_id  = yandex_vpc_subnet.subnet["central1-d"].id
#     nat        = true
#     ip_address = "10.0.3.12"
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#   }
# }

# module "yandex_cluster" {
#   source = "./modules/yandex-cluster"
#   cluster_size = var.cluster_size
# }

