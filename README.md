# Дипломный практикум в Yandex.Cloud
## Выполнил студент группы SHDEVOPS-21 Александров С.П.

### Цели:
1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.


### Этапы выполнения:
## 1. Создание облачной инфраструктуры.
Подготовлена [terraform конфигурация](https://github.com/Sem20071/netology_final_project/tree/main/1_service-account-yc) для создания сервисного аккаунта и s3 bucket в YC и KMS ключа для шифрования содержимого bucket.
* Все файлы с чувствительными данными добавлены в .gitignore
* S3 Bucket создается и шифруется созданным ключом.
  ![Bucket создан](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-1-1.png)
  ![Файл terraform.tfstate зашифрован](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-1-2.png)
* Команды `terraform destroy` и `terraform apply` выполняются без дополнительных ручных действий.
  ![Terraform apply](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-1-3.png)
  ![Terraform destroy](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-1-4.png)

## 2. Создание Kubernetes кластера.
1. Для создания kubernetes кластера был выбран вариант с созданием виртуальных машин Compute Cloud и их настройкой при помощи Ansible. Была подготовлена [terraform конфигурация](https://github.com/Sem20071/netology_final_project/tree/main/2_main) и [ansible-playbook](https://github.com/Sem20071/netology_final_project/tree/main/2_main/ansible-config-k8s-cluster). Настройку k8s кластера реализовал при помощи инструментов Ansible + RKE2. 
2. После запуска terraform конфигурации создаются сл. компоненты:
* Настраиваться сетевая инфраструктура. Создаются сеть и подсети.
* Создаётся требуемое количество виртуальных машин.
* Производится настройка виртуальных машин согласно [cloud-init конфигурации](https://github.com/Sem20071/netology_final_project/blob/main/2_main/cloud-init.yml)
* При помощи Ansible настраивается kubernetes на всех машинах кластера.
![Результат выполнения terraform apply.1](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-2-1.png)
![Результат выполнения terraform apply.2](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-2-2.png)
![Результат выполнения terraform apply.2](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-2-3.png)
![Результат выполнения kubectl get pods --all-namespaces](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-2-4.png)
![Результат выполнения kubectl get nodes](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-2-5.png)

## 3. Создание тестового приложения.
1. Подготовлен [отдельный GitHub репозиторий](https://github.com/Sem20071/my-mini-app) для тестового приложения.
2. Подготовлен [Dockerfile](https://github.com/Sem20071/my-mini-app/blob/main/Dockerfile) для создания образа приложения.
3. [Ссылка на образ в DockerHub](https://hub.docker.com/repository/docker/aleksandrovsp/aleksandrov-my-miniapp/general)
   Собираем и загружаем образ в репозиторий DockerHub
   ![Результат выполнения docker build -t aleksandrovsp/aleksandrov-my-miniapp:1.0.0 .](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-3-1.png)
   ![Результат выполнения docker push aleksandrovsp/aleksandrov-my-miniapp:1.0.0](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-3-2.png)

## 4. Подготовка системы мониторинга и деплой приложения.
1. Подготовлен [манифест](https://github.com/Sem20071/my-mini-app/blob/main/deployment-my-app.yaml) для разворачивания тестового приложения
2. Подготовлен [манифест](https://github.com/Sem20071/my-mini-app/blob/main/grafana-config.yaml) для внесения изменений в конфигурациию мониторинг кластера. При разворачивании воспользовался пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)
3. Подготовлен [bash скрипт](https://github.com/Sem20071/my-mini-app/blob/main/deploy.sh) для упрощения развертывания всех выше перечисленных компонентов.
![Результат выполнения скрипта deploy.sh](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-4-1.png)


## 5. Деплой инфраструктуры в terraform pipeline.
Для деплоя инфраструктуры в terraform pipeline я выбрал GitHub Action т.к. ранее ужа работал с ним и по моему мнению он достаточно удобен. На этом этапе были внесены изменения в основную Terraform конфигурацию:
1. Все чувствительные даннеы были вынесены в переменные окружения и добавлены в GitHub Actions secrets and variables.
2. Добавлен код для создания:
   * Application Load Balancer и роутера в YC. Это необходимо для организации доступа к тестовому приложению и интерфейсу Grafana через 80 порт.
   * Целевой группы хостов.
   * backend group для тестового приложения и Grafana с healthcheck
   * Виртуального хоста для настройки маршрутизации.
3. Создан [GitHub Action Workflow](https://github.com/Sem20071/netology_final_project/blob/main/.github/workflows/terraform-deployment.yml)
   
Пушим изменения ветку main проекта и проверяем.
![Результат выполнения git push](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-1.png)
![выполнение GitHub Action](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-2.png)
![выполнение GitHub Action](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-3.png)
![выполнение GitHub Action](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-4.png)
Забираем конфиг файл и артифактов.
![выполнение GitHub Action](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-5.png)
Проверяем состояние развернутого кластера
![Результат выполнения ](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-5.png)
Разворачиваем в кластере k8s тестовое приложение и мониторинг.
Проверяем доступность тестового приложения.
![Доступность тестовой страницы на 80 порту](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-6.png)

Проверяем доступность grafana.
![Доступность grafana на 80 порту](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-7.png)
![Дашборд](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-5-8.png)

[GitHub репозиторий с конфигурационными файлами для настройки Kubernetes](https://github.com/Sem20071/netology_final_project/tree/main/2_main)

## 6. Установка и настройка CI/CD.
Для настройки CI/CD так же был выбран GitHub Action. Создан [GitHub workflow](https://github.com/Sem20071/my-mini-app/blob/main/.github/workflows/deploy-app.yml).
Проверяем версию образа в deployment
![Результат выполнения kubectl describe deployments.apps my-mini-app](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-6-1.png)

![Пушим изменения, в ветку main, с тэгом v1.0.1](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-6-2.png)

![Проверяем как отработал созданный workflow. 1](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-6-3.png)
![Проверяем как отработал созданный workflow. 2](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-6-4.png)
![Проверяем DockerHub регистри, видим что новый образ с тэгом v1.0.1 а так же тот же образ но с тэго latest загружены](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-6-5.png)
![Открываем нашу тестовую страницу и видим изменения](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-6-6.png)
[Проверяем версию образа в deployment и видим что версия изменена на v1.0.1](https://github.com/Sem20071/netology_final_project/blob/main/images/Diplom-AleksandrovSP-6-7.png)

# Результат выполнения дипломной работы.
1. [Репозиторий с конфигурационными файлами Terraform](https://github.com/Sem20071/netology_final_project)
2. [Terraform pipeline](https://github.com/Sem20071/netology_final_project/blob/main/.github/workflows/terraform-deployment.yml)
3. [Репозиторий с конфигурацией ansible для настройки кластера k8s](https://github.com/Sem20071/netology_final_project/tree/main/2_main/ansible-config-k8s-cluster)
4. [Репозиторий с Dockerfile тестового приложения](https://github.com/Sem20071/my-mini-app) и [ссылка на собранный docker image](https://hub.docker.com/repository/docker/aleksandrovsp/aleksandrov-my-miniapp/general)
5. [Репозиторий с конфигурацией Kubernetes кластера](https://github.com/Sem20071/netology_final_project/tree/main/2_main)
6. [Ссылка на тестовое приложение]() и [веб интерфейс Grafana с данными доступа]()
7. Все репозитории с исходниками распологаются в GitHub








   
