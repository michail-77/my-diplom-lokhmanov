resource "yandex_compute_instance" "cluster_node" {
  count = var.cluster_size

  # Остальные параметры узла кластера
  # ...
}
