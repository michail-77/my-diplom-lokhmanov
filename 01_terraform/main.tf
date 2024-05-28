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

# Создание экземпляев на основе списка нод
resource "yandex_compute_instance" "nodes" {
  for_each = local.nodes

  name                     = each.key
  hostname                 = each.key
  zone                     = each.value.zone
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
    subnet_id  = yandex_vpc_subnet.subnet[each.value.subnet_id].id
    nat        = true
    ip_address = "10.0.${each.value.ip_offset}.11"
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}