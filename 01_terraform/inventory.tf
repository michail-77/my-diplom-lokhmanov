resource "local_file" "ansible_inventory" {
  filename = "/mnt/d/Netology/Diplom/kubespray/inventory/mycluster/hosts.yml"
  content  = <<EOF
all:
  hosts:
    master:
      ansible_host: ${yandex_compute_instance.master.network_interface.0.nat_ip_address}
      ip: ${yandex_compute_instance.master.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.master.network_interface.0.ip_address}
      ansible_user: ubuntu
      ansible_ssh_common_args: "-i ~/.ssh/id_rsa"
    node1:
      ansible_host: ${yandex_compute_instance.node1.network_interface.0.nat_ip_address}
      ip: ${yandex_compute_instance.node1.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.node1.network_interface.0.ip_address}
      ansible_user: ubuntu
      ansible_ssh_common_args: "-i ~/.ssh/id_rsa"
    node2:
      ansible_host: ${yandex_compute_instance.node2.network_interface.0.nat_ip_address}
      ip: ${yandex_compute_instance.node2.network_interface.0.ip_address}
      access_ip: ${yandex_compute_instance.node2.network_interface.0.ip_address}
      ansible_user: ubuntu
      ansible_ssh_common_args: "-i ~/.ssh/id_rsa"

  children:
    kube_control_plane:
      hosts:
        master:
    kube_node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        master:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
EOF
}



# teamcity-server:
#   ansible_host: ${yandex_compute_instance.teamcity-server.network_interface.0.nat_ip_address}
#   ip: ${yandex_compute_instance.teamcity-server.network_interface.0.ip_address}
#   access_ip: ${yandex_compute_instance.teamcity-server.network_interface.0.ip_address}
#   ansible_user: ubuntu
#   ansible_ssh_common_args: "-i ~/.ssh/id_rsa"
# teamcity-agent:
#   ansible_host: ${yandex_compute_instance.teamcity-agent.network_interface.0.nat_ip_address}
#   ip: ${yandex_compute_instance.teamcity-agent.network_interface.0.ip_address}
#   access_ip: ${yandex_compute_instance.teamcity-agent.network_interface.0.ip_address}
#   ansible_user: ubuntu
#   ansible_ssh_common_args: "-i ~/.ssh/id_rsa"