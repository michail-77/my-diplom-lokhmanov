# Дипломный практикум в Yandex.Cloud
- [Дипломный практикум в Yandex.Cloud](#дипломный-практикум-в-yandexcloud)
  - [Цели:](#цели)
  - [Этапы выполнения:](#этапы-выполнения)
    - [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
    - [Решение:](#решение)
    - [Создание Kubernetes кластера](#создание-kubernetes-кластера)
    - [Решение:](#решение-1)
    - [Создание тестового приложения](#создание-тестового-приложения)
    - [Решение:](#решение-2)
    - [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
    - [Решение:](#решение-3)
    - [Установка и настройка CI/CD](#установка-и-настройка-cicd)
    - [Решение.](#решение-4)
  - [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
- Следует использовать версию [Terraform](https://www.terraform.io/) не старше 1.5.x .

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

### Решение:  
1. Создаем сервисный аккаунт в [yandex cloud] (https://yandex.cloud/ru/docs/iam/operations/sa/create) согласно инструкции и назначаем ему роли.
```
   $ yc iam service-account list
+----------------------+-----------+
|          ID          |   NAME    |
+----------------------+-----------+
| ajec47hqj2hk2peqj980 | admin     |
| ajeetedg476jfgrmn6mn | editor    |
| ajeupl64gvqlbfab689f | bucket-sa |
+----------------------+-----------+
```
   ![6](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/6_service%20account.png)
   Создаем service-accoun-key и authorized_key.json
```
$ yc config list
service-account-key:
  id: ajeh5j1gqvn0qhd459q5
  service_account_id: ajeetedg476jfgrmn6mn
  created_at: "2024-05-02T15:33:45.556389551Z"
  key_algorithm: RSA_2048
  public_key: |
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAA...
    -----END PUBLIC KEY-----
  private_key: |
    PLEASE DO NOT REMOVE THIS LINE! Yandex.Cloud SA Key ID <ajeh5j1...qhd459q5>
    -----BEGIN PRIVATE KEY-----
    MIIEvgIBADANBgkqhkiG9w0BAQ...
    -----END PRIVATE KEY-----
cloud-id: b1ghns2saijtpp8com7i
folder-id: b1gb5mplcv6bu0g0eolj
compute-default-zone: ru-central1

$ yc config set service-account-key authorized_key.json

```
  
2. Устанавливаем и настраиваем [terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart)  
   Подготавливаем конфигурацию [Terraform](https://github.com/michail-77/my-diplom-lokhmanov/tree/main/01_terraform)  
   Перед запуском проверим конфигурацию командой terraform validate.
```
user@DESKTOP-RAJIAFA:/mnt/d/Netology/Diplom/my-diplom-lokhmanov/01_terraform$ terraform validate
Success! The configuration is valid.
   
user@DESKTOP-RAJIAFA:/mnt/d/Netology/Diplom/my-diplom-lokhmanov/01_terraform$ terraform plan
data.yandex_compute_image.public-ubuntu: Reading...
yandex_kms_symmetric_key.key-a: Refreshing state... [id=abj49aohkpme1rnhtuan]
yandex_iam_service_account.bucket-sa: Refreshing state... [id=ajes4f4lk8olvqslma45]
yandex_vpc_network.develop: Refreshing state... [id=enp45e57ul75o0r4503i]
data.yandex_compute_image.public-ubuntu: Read complete after 0s [id=fd852pbtueis1q0pbt4o]
yandex_iam_service_account_static_access_key.sa-static-key: Refreshing state... [id=ajegj8vovp501rkjvbh8]
yandex_vpc_subnet.subnet["central1-a"]: Refreshing state... [id=e9b6ajbl7jtje54vlt9j]
yandex_vpc_subnet.subnet["central1-b"]: Refreshing state... [id=e2lj6jl8ldcmh7067ktt]
yandex_vpc_subnet.subnet["central1-d"]: Refreshing state... [id=fl8satavjhnb5kjj2me9]
yandex_compute_instance.node1: Refreshing state... [id=epd20nou1lk7t81r073n]
yandex_compute_instance.node2: Refreshing state... [id=fv4gg7pudf3dnq5laui2]
yandex_compute_instance.master: Refreshing state... [id=fhms3m9vp9h4jekj0cih]
local_file.ansible_inventory: Refreshing state... [id=cd00f3fb7a498abd77cd401225a1ed65752367b2]
Note: Objects have changed outside of Terraform
Terraform detected the following changes made outside of Terraform since the last "terraform apply" which may have  
affected this plan:
  # yandex_compute_instance.master has changed
  ~ resource "yandex_compute_instance" "master" {
        id                        = "fhms3m9vp9h4jekj0cih"
        name                      = "master"
        # (11 unchanged attributes hidden)
      ~ network_interface {
          - nat_ip_address     = "51.250.2.231" -> null
            # (9 unchanged attributes hidden)
        }
        # (5 unchanged blocks hidden)
    }
  # yandex_compute_instance.node1 has changed
  ~ resource "yandex_compute_instance" "node1" {
        id                        = "epd20nou1lk7t81r073n"
        name                      = "node1"
        # (11 unchanged attributes hidden)

      ~ network_interface {
          - nat_ip_address     = "158.160.92.91" -> null
            # (9 unchanged attributes hidden)
        }
        # (5 unchanged blocks hidden)
    }
  # yandex_compute_instance.node2 has changed
  ~ resource "yandex_compute_instance" "node2" {
        id                        = "fv4gg7pudf3dnq5laui2"
        name                      = "node2"
        # (11 unchanged attributes hidden)
      ~ network_interface {
          - nat_ip_address     = "158.160.167.27" -> null
            # (9 unchanged attributes hidden)
        }
        # (5 unchanged blocks hidden)
    }
Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using
ignore_changes, the following plan may include actions to undo or respond to these changes.
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with 
the following symbols:
-/+ destroy and then create replacement
Terraform will perform the following actions:
  # local_file.ansible_inventory must be replaced
-/+ resource "local_file" "ansible_inventory" {
      ~ content              = <<-EOT # forces replacement
            all:
              hosts:
                master:
          -       ansible_host: 51.250.2.231
          +       ansible_host:
                  ip: 10.0.1.10
                  access_ip: 10.0.1.10
                  ansible_user: ubuntu
                  ansible_ssh_common_args: "-i /root/.ssh/id_rsa"
                node1:
          -       ansible_host: 158.160.92.91
          +       ansible_host:
                  ip: 10.0.2.11
                  access_ip: 10.0.2.11
                  ansible_user: ubuntu
                  ansible_ssh_common_args: "-i /root/.ssh/id_rsa"
                node2:
          -       ansible_host: 158.160.167.27
          +       ansible_host:
                  ip: 10.0.3.12
                  access_ip: 10.0.3.12
                  ansible_user: ubuntu
                  ansible_ssh_common_args: "-i /root/.ssh/id_rsa"
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
        EOT
      ~ content_base64sha256 = "fYhH4Lfa/9SPSHGF1EIKp8Lix2UVz6CTA8vzeNgg5dg=" -> (known after apply)
      ~ content_base64sha512 = "+mTVPBhS+f+lEuYiv5LleM2n4siAZqCn7DvJm6ZVDmKaIWwgGUaCJ1nVH27SUzJDU5+nL7hBDEDxz/jqHJnk8w==" -> (known after apply)
      ~ content_md5          = "26924e1d9ed94137f309bfd82da86c71" -> (known after apply)
      ~ content_sha1         = "cd00f3fb7a498abd77cd401225a1ed65752367b2" -> (known after apply)
      ~ content_sha256       = "7d8847e0b7daffd48f487185d4420aa7c2e2c76515cfa09303cbf378d820e5d8" -> (known after apply)
      ~ content_sha512       = "fa64d53c1852f9ffa512e622bf92e578cda7e2c88066a0a7ec3bc99ba6550e629a216c201946822759d51f6ed2533243539fa72fb8410c40f1cff8ea1c99e4f3" -> (known after apply)
      ~ id                   = "cd00f3fb7a498abd77cd401225a1ed65752367b2" -> (known after apply)
        # (3 unchanged attributes hidden)
    }
Plan: 1 to add, 0 to change, 1 to destroy.
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 
Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions  
if you run "terraform apply" now.
```
3. Выполняем команду terraform apply и у нас без дополнительных ручных действий разворачивается инфраструктура в яндекс облаке.
   ![1](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/1_вирт_машины.png)  
   ![2](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/2_сети.png)  
   ![3](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/3_подсети_yc.png)  
   ![4](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/4_сервис_аккаунт.png)  
   ![5](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/5_бакет.png)  

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

### Решение:  
1. a. На предыдущем шаге мы подготовили инфраструктуру для разворачивания kubernetes кластера и файл [hosts.yml](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/02_kubernetes/hosts.yml).  
   б. Будем использовать [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/).  
      Для этого клонируем репозиторий [Kubespray](https://github.com/kubernetes-sigs/kubespray) к себе.
      Установим зависимости:
```
$ ansible-galaxy install -r requirements.yml
Starting galaxy collection install process
Process install dependency map
Cloning into '/home/user/.ansible/tmp/ansible-local-432965cm3702v/tmpp9rpr3o9/kubespray7dhh390_'...
```        
      В папке inventory/sample есть пример с набором ролей Ansible для создания кластера, скопируем его, переименуем в inventory/mycluster и так же в mycluster скопируем файл hosts.yml.  
      Теперь перейдём в папку конфигурации Ansible и инициализуем создание кластера:  
```
$ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml 
```  
![7](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/7_cluster.png)  
Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок  
![8](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/8_namespace%20pods.png)  
файл `~/.kube/config` выглядит так
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQW...
    server: https://178.154.224.67:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJ...
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBM3dzY0du...
```

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

### Решение:  
Создал git репозиторий [nginx](https://github.com/michail-77/nginx) и [Dockerfile](https://github.com/michail-77/nginx/blob/main/Dockerfile).  
[DockerHub](https://hub.docker.com) с собранным [docker image](https://hub.docker.com/repository/docker/michail77/image_nginx/general).  
![9](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/9_Docker_image_nginx_2.png)  
![10](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/10_Docker_image_nginx.png)  

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.
### Решение:  
Развернём систему мониторинга с помощью Kube-Prometheus.
Зайдёт на Master и склонируем репозиторий: 
#git clone https://github.com/prometheus-operator/kube-prometheus.git
Переходим в каталог с kube-prometheus и развертываем контейнеры:
 $sudo kubectl apply --server-side -f manifests/setup
 $sudo kubectl apply -f manifests/
```
ubuntu@master:~/kube-prometheus$ sudo kubectl get po -n monitoring -o wide
NAME                                   READY   STATUS    RESTARTS        AGE     IP               NODE     NOMINATED NODE   READINESS GATES
alertmanager-main-0                    1/2     Running   1 (48s ago)     2m38s   10.233.75.31     node2    <none>           <none>
alertmanager-main-1                    1/2     Running   1 (46s ago)     2m37s   10.233.75.9      node2    <none>           <none>
alertmanager-main-2                    1/2     Running   1 (47s ago)     2m38s   10.233.75.27     node2    <none>           <none>
blackbox-exporter-7c7f95db96-2vv24     3/3     Running   3 (6m21s ago)   13h     10.233.102.169   node1    <none>           <none>
grafana-85c87f8769-fs27l               1/1     Running   1 (6m21s ago)   13h     10.233.102.159   node1    <none>           <none>
kube-state-metrics-699859d994-m7ns2    3/3     Running   5 (109s ago)    13h     10.233.102.160   node1    <none>           <none>
node-exporter-d82sk                    2/2     Running   2 (5m35s ago)   22h     10.0.1.10        master   <none>           <none>
node-exporter-mx6m6                    2/2     Running   2 (7m20s ago)   22h     10.0.3.12        node2    <none>           <none>
node-exporter-qrczs                    2/2     Running   4 (6m21s ago)   22h     10.0.2.11        node1    <none>           <none>
prometheus-adapter-77f8587965-9w8f6    1/1     Running   2 (107s ago)    7h39m   10.233.102.155   node1    <none>           <none>
prometheus-adapter-77f8587965-lx644    1/1     Running   3 (107s ago)    13h     10.233.102.163   node1    <none>           <none>
prometheus-k8s-0                       2/2     Running   0               2m38s   10.233.75.62     node2    <none>           <none>
prometheus-k8s-1                       2/2     Running   2 (6m21s ago)   9h      10.233.102.164   node1    <none>           <none>
prometheus-operator-586f75fb74-92fvk   2/2     Running   3 (105s ago)    7h39m   10.233.102.161   node1    <none>           <none>
```
Для доступа к интерфейсу изменим сетевую политику и запустим manifest/grafana-service:
```
root@master:/home/ubuntu# sudo kubectl -n monitoring apply -f manifest/grafana-service.yml
service/grafana configured
networkpolicy.networking.k8s.io/grafana configured
```
Http доступ к web интерфейсу grafana (http://158.160.49.210:30001).
![11](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/11_grafana.png)  

Деплоим приложение
```
$ kubectl apply -f dep-my-nginx.yml    
namespace/netology created
deployment.apps/my-app created
service/nginx-my created
$ k get pods -n netology
NAME                     READY   STATUS    RESTARTS   AGE
my-app-7b4b84c86-mrjmm   1/1     Running   0          2m5s
my-app-7b4b84c86-prpk5   1/1     Running   0          82s
```


---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

### Решение. 
```
Разбираюсь и пытаюсь доделать.(
и если не затруднит, не могли бы помочь... или немного подождать, я за выходные постараюсь доделать.
```  

Для автоматической сборки docker image и деплоя приложения при изменении кода буду использовать [Github actions](https://docs.github.com/ru/actions)  
CI-CD.yaml лежит [тут](https://github.com/michail-77/nginx/blob/main/.github/workflows/ci-cd.yaml)  

Настраивал по данной статье https://nicwortel.nl/blog/2022/continuous-deployment-to-kubernetes-with-github-actions , но что-то не получается с автоизацией разобраться.
![12](https://github.com/michail-77/my-diplom-lokhmanov/blob/main/image/12_cicd.png)



---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

