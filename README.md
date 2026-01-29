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
Подготовлена [terraform конфигурация](https://github.com/Sem20071/netology_final_project/tree/main/1_service-account-yc) для создания сервисного аккаунта и s3 bucket в YC и KMS ключа для шифрования бакета.
* Все файлы с чувствительными данными добавлены в .gitignore
* S3 Bucket создается и шифруется созданым ключем.
  ![Bucket создан]()
  ![Файл terraform.tfstate зашифрован]()
* Команды `terraform destroy` и `terraform apply` выполняются без дополнительных ручных действий.
  ![Terraform apply]()
  ![Terraform destroy]()

## 2. Создание Kubernetes кластера.
1. Для создания kubernetes кластера был выбран вариант с созданием виртуальных машин Compute Cloud и их настройкой при помощи Ansible. Была подготовлена [terraform конфигурация](https://github.com/Sem20071/netology_final_project/tree/main/2_main) и [ansible-playbook](https://github.com/Sem20071/netology_final_project/tree/main/2_main/ansible-config-k8s-cluster). Настройку k8s кластера реализовал при помощи инструментов Ansible + RKE2. 
2. После запуска terraform конфигурации создаются сл. компоненты:
* Настраиваться сетевая инфраструктура. Создаются сеть и подсети.
* Создаётся требуемое количество виртуальных машин.
* Производится настройка виртуальных машин согласно [cloud-init конфигурации](https://github.com/Sem20071/netology_final_project/blob/main/2_main/cloud-init.yml)
* Про помощи Ansible настраивается kubernetes на всех машинах кластера.
![Результат выполнения terraform apply.1]()
![Результат выполнения terraform apply.2]()
![Результат выполнения kubectl get pods --all-namespaces]()
![Результат выполнения kubectl get nodes]()

## 3. Создание тестового приложения.
1. Подготовлен [отдельный GitHub репозиторий](https://github.com/Sem20071/my-mini-app) для тестового приложения.
2. Подготовлен [Dockerfile](https://github.com/Sem20071/my-mini-app/blob/main/Dockerfile) для создания образа приложения.
3. [Ссылка на образ в DockerHub](https://hub.docker.com/repository/docker/aleksandrovsp/aleksandrov-my-miniapp/general)
   Собираем и загружаем образ в репозиторий DockerHub
   ![Результат выполнения docker build -t aleksandrovsp/aleksandrov-my-miniapp:1.0.0 .]()
   ![Результат выполнения docker push aleksandrovsp/aleksandrov-my-miniapp:1.0.0]()

## 4. Подготовка cистемы мониторинга и деплой приложения.
1. Подготовлен [манифест](https://github.com/Sem20071/my-mini-app/blob/main/deployment-my-app.yaml) для разворачивания тестового приложения
2. Подготовлен [манифест](https://github.com/Sem20071/my-mini-app/blob/main/grafana-config.yaml) для внесения изменений в конфигурациию мониторинг кластера. При разворачивнаии воспользовался пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)
3. Подготовлен [bash скрипт](https://github.com/Sem20071/my-mini-app/blob/main/deploy.sh) для упращения развертывания всех выше перечисленных компонентов.
![Результат выполнения скрипта deploy.sh]()


## 5. Деплой инфраструктуры в terraform pipeline.
Для деплоя инфраструктуры в terraform pipeline я выбрал GitHub Action т.к. ранее ужа работал с ним и по моему мненю он достаточно удобен. На этом этапе были внесены изменения в основнаю Terraform конфигурацию:
1. Все чувствительные даннеы были вынесены в переменные окружения и добавлены в GitHub Actions secrets and variables.
2. Добавлен код для создания:
   * Application Load Balancer и роутера в YC. Это необходимо для организации доступа к тестовому приложению и интерфейсу Grafana через 80 порт.
   * Целевой группы хостов.
   * backend group для тестового приложения и Grafana с healthcheck
   * Виртуального хоста для настройки маршрутизации.
3. Создани [GitHub Action Workflow](https://github.com/Sem20071/netology_final_project/blob/main/.github/workflows/terraform-deployment.yml)
   
Пушим изменения ветку main проекта и проверяем.
![Результат выполнения git push]()
![выполнение GitHub Action]()
![выполнение GitHub Action]()
![выполнение GitHub Action]()
![выполнение GitHub Action]()
Забираем конфиг файл и артифактов.
![выполнение GitHub Action]()
Проверяем состояние развернутого кластера
![Результат выполнения ]()
Разворачиваем в кластере k8s тестовое приложение и мониторинг.
Проверяем доступность тестового приложения.
![Доступность тестовой страницы на 80 порту]()

Проверяем доступность grafana.
![Доступность grafana на 80 порту]()
![Дашборд]()

[GitHub репозиторий с конфигурационными файлами для настройки Kubernetes]()

## 6. Установка и настройка CI/CD.
Для настройки CI/CD так же был выбран GitHub Action. Создан [GitHub workflow](https://github.com/Sem20071/my-mini-app/blob/main/.github/workflows/deploy-app.yml).
Проверяем версию образа в deployment
![Результат выполнения kubectl describe deployments.apps my-mini-app]()

[Пушим изменения, в ветку main, с тэгом v1.0.1]()

[Проверяем как отработал созданный workflow. 1]()
[Проверяем как отработал созданный workflow. 2]()
[Проверяем DockerHub регистри, видим что новый образ с тэгом v1.0.1 а так же тот же образ но с тэго latest загружены]()
[Открываем нашу тестовую страницу и видим изменения]()
[Проверяем версию образа в деплоймент и видим что версия изменена на v1.0.1]()

# Результат ввыполнения дипломной работы.
1. [Репозиторий с конфигурационными файлами Terraform](https://github.com/Sem20071/netology_final_project)
2. [Terraform pipeline](https://github.com/Sem20071/netology_final_project/blob/main/.github/workflows/terraform-deployment.yml)
3. [Репозиторий с конфигурацией ansible для настройки кластера k8s](https://github.com/Sem20071/netology_final_project/tree/main/2_main/ansible-config-k8s-cluster)
4. [Репозиторий с Dockerfile тестового приложения](https://github.com/Sem20071/my-mini-app) и [ссылка на собранный docker image](https://hub.docker.com/repository/docker/aleksandrovsp/aleksandrov-my-miniapp/general)
5. [Репозиторий с конфигурацией Kubernetes кластера](https://github.com/Sem20071/netology_final_project/tree/main/2_main)
6. [Ссылка на тестовое приложение]() и [веб интерфейс Grafana с данными доступа]()
7. Все репозитории с исходниками распологаются в GitHub









   
