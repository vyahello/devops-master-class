# Azure devops 

Allows continuous integration, deployment and delivery of software.

Create Azure account and go to https://portal.azure.com 

Go to https://dev.azure.com

### Create Azure devops project 

https://dev.azure.com/vjagello93/azure-devops-kuber-terra

- Go to pipelines and select github repo 
- Create YAML pipeline. In case of pool issues you need to configure self-hosted pool via https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-osx?view=azure-devops
- Click run and commit the pipeline 
- Check pipeline config: [azure-pipelines.yml](pipelines/01-azure-pipelines-jobs.yml)
- Check job result via https://dev.azure.com/vjagello93/azure-devops-kuber-terra/_build
- Check raw logs via https://dev.azure.com/vjagello93/5d787896-6c24-4ff8-b513-68c46c6bb846/_apis/build/builds/6/logs/10

### DependsOn 

```yaml
# 02-azure-pipelines-stages.yml

jobs:
- job: Job1
  steps:
  # task 1
  - script: echo Job1 - Hello, world!
    displayName: 'Run a one-line script'

- job: Job2
  dependsOn: Job1
  steps:
  # task 1
  - script: echo Job2
    displayName: 'Run a one-line script'
```

### Stages 

```yaml
stages:
- stage: Build
  jobs:
  - job: FirstJob
    steps:
    - bash: echo Build FirstJob
  - job: SecondJob
    steps:
    - bash: echo Build SecondJob
- stage: DevDeploy
  # add stage dependency
  dependsOn: Build
  jobs:
  - job: DevDeployJob
    steps:
    - bash: echo Build DevDeployJob
```

### Variables 

```yaml
stages:
- stage: Build
  jobs:
  - job: FirstJob
    steps:
    - bash: echo $(PipelineLevel)  # var is added in UI
- stage: DevDeploy
  # add stage dependency
  dependsOn: Build
  # add env variable
  variables:
    environment: dev
  jobs:
  - job: DevDeployJob
    steps:
    - bash: echo $(environment)DeployJob
```

Predefined vars - https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops&tabs=yaml

```yaml
    steps:
    - bash: echo Build SecondJob
    - bash: echo $(PipelineLevel)
    - bash: echo $(Build.BuildNumber)
    - bash: echo $(Build.BuildId)
    - bash: echo $(Build.SourcesBranchName)
    - bash: echo $(Build.SourcesDirectory)
    - bash: ls -R $(System.DefaultWorkingDirectory)
    - bash: echo $(Build.ArtifactStagingDirectory)
```

### Copy and publish artifacts 

Add config via UI:
- Source folder - $(System.DefaultWorkingDirectory)
- Contents - **/*.yaml, **/.tf
- Target folder - $(Build.ArtifactStagingDirectory)

Add config via cmd:
```yaml
    # copying files
    - task: CopyFiles@2
      inputs:
        SourceFolder: '$(System.DefaultWorkingDirectory)'
        Contents: |
          **/*.yaml
          **/.tf
        TargetFolder: '$(Build.ArtifactStagingDirectory)'
    - bash: ls -R $(Build.ArtifactStagingDirectory)

    # publish artifacts
    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'drop'
        publishLocation: 'Container'
```

Check 'drop' folder artifact.

### Multiple agents

```yaml
strategy:
  matrix:
    linux:
      operatingSystem: 'ubuntu-latest'
    mac:
      operatingSystem: 'macos-latest'
```

### Deployment job 

```yaml
- stage: QADeploy
  jobs:
  # we have one job which is a deployment
  - deployment: QADeployJob
    # will be deployed on QA env 
    environment: QA
    strategy:
      runOnce:
        deploy:
          steps:
          - script: echo deploy to QA
```

- Go to https://dev.azure.com/vjagello93/azure-devops-kuber-terra/_environments to check environments.
- You can add 'Approvals' option for your job. 

### Build and publish Docker image 

Go to 'Service connection' and give permission to docker hub

```yaml
stages:
- stage: Build
  displayName: Build image
  jobs:
  - job: Build
    displayName: Build
    pool: SelfPool
    steps:
    - task: Docker@2
      displayName: Build an image
      inputs:
        containerRegistry: 'in28min-docker-hub'
        repository: 'vyahello/currency-exchange'
        command: 'buildAndPush'
        Dockerfile: '**/Dockerfile'
        tags: '$(tag)'
```


### Azure devops releases

https://dev.azure.com/vjagello93/azure-devops-kuber-terra/_release?_a=releases&view=mine&definitionId=1

Go to 'Releases' and create a new pipeline. 

Used `02-azure-pipelines-stages.yml` file.

Release after push into branch -> Stages to deploy: Dev (run always), QA (run after manual approval)

# Azure AKS with terraform 

AKS - azure kubernetes service.

Install az client via `brew update && brew install azure-cli`

```bash
az login
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "1deabc10-cbcc-4a75-aadb-73c8a58f7b4b",
    "id": "0ebe5978-3106-4ed2-abbf-f6f618a840b6",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Free trial",
    "state": "Enabled",
    "tenantId": "1deabc10-cbcc-4a75-aadb-73c8a58f7b4b",
    "user": {
      "name": "vjagello93@gmail.com",
      "type": "user"
    }
  }
]

# create service account, which has access to everything
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/0ebe5978-3106-4ed2-abbf-f6f618a840b6"
# create ssh public key
ssh-keygen -m PEM -t rsa -b 4096
```

## Create K8s cluster in Azure using Azure DevOps

Go to service connections -> New Service Connection -> Azure Service Manager 

Install:
- Terraform 1 (https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
- Terraform 2 (https://marketplace.visualstudio.com/items?itemName=charleszipp.azure-pipelines-tasks-terraform)
- Aws (https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-vsts-tools)

Go to "Pipelines" and create new pipeline.

Check config in [keys](configuration/iaac/azure/k8s/.keys) file:
- $(client_id) var is "appId"
- $(client_secret) var is "password"
- In "Library" add "Secure files" for ssh key and in "Pipelines" add "Download Secure Files"

Terraform creates a cluster, Azure devops - where your pipelines are running, Azure - cloud provider.

```yaml
# 05-azure-k8s-iaac-cluster-pipeline.yml

trigger:
- master

pool: SelfPool

steps:
- script: echo K8S Terraform Azure!
  displayName: 'Run a one-line script'

- task: DownloadSecureFile@1
  name: publickey
  inputs:
    secureFile: 'azure_rsa.pub'
    retryCount: '5'

- task: TerraformCLI@0
  inputs:
    command: 'init'
    workingDirectory: '$(System.DefaultWorkingDirectory)/ci_cd/azure_devops_pipelines/configuration/iaac/azure/k8s'
    commandOptions: '-var client_id=$(client_id) -var client_secret=$(client_secret) -var ssh_public_key=$(publickey.secureFilePath)'
    backendType: 'azurerm'
    backendServiceArm: 'azure-resource-manager-service-connection'
    ensureBackend: true
    backendAzureRmResourceGroupName: 'terraform-backend-rg'
    backendAzureRmResourceGroupLocation: 'westeurope'
    backendAzureRmStorageAccountName: 'storageaccvyah'
    backendAzureRmContainerName: 'storageaccvyah'
    backendAzureRmKey: 'k8s-dev.tfstate'
```

Go to https://portal.azure.com and check for resource groups -> storage account -> container.


### Terraform apply to create Azure Kubernetes Cluster in Azure

```yaml
# terraform apply part
- task: TerraformCLI@0
  inputs:
    command: 'apply'
    workingDirectory: '$(System.DefaultWorkingDirectory)/ci_cd/azure_devops_pipelines/configuration/iaac/azure/k8s'
    commandOptions: '-var client_id=$(client_id) -var client_secret=$(client_secret) -var ssh_public_key=$(publickey.secureFilePath)'
    environmentServiceName: 'azure-resource-manager-service'
```

It will initially run `terraform init` and then `terraform apply` commands.

### Connect to Azure Kubernetes Cluster

```bash
az login
az aks get-credentials --name=k8stest_dev --resource-group=kubernetes_dev
kubectl get svc

NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.0.0.1    <none>        443/TCP   6d14h
```

### Deploy microservice to Azure AKS with K8S 

We are setup CI/CD pipeline for IAAC, you can increase n of nodes, change your kubernetes cluster just by commiting something to github repository.

Same as for your code, you setup CI/CD around your code, when you made changes, it will be automatically picked up and deployed.

Idea (made automatically by CI/CD):
  - push code on github
  - build and push docker image
  - use docker image in k8s cluster 
  - deploy app in azure k8s cloud with new changes 

Configure connection to the kubernetes cluster via 'Service connections'.

```yaml
# 06-azure-kubernetes-ci-ci.yml

trigger:
- master

resources:
- repo: self

variables:
  # tag: '$(Build.BuildId)'
  tag: 29

stages:
# Stage 1
# Build Docker image 
- stage: Build
  displayName: Build image
  jobs:
  - job: Build
    displayName: Build
    pool: SelfPool
    steps:
    - task: Docker@2
      displayName: Build an image
      inputs:
        containerRegistry: 'in28min-docker-hub'
        repository: 'vyahello/currency-exchange'
        command: 'buildAndPush'
        Dockerfile: '**/Dockerfile'
        tags: '$(tag)'
    - task: CopyFiles@2
      inputs:
        SourceFolder: '$(System.DefaultWorkingDirectory)'
        Contents: '**/*.yml'
        TargetFolder: '$(Build.ArtifactStagingDirectory)'
    # create artifacts
    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'manifests'
        publishLocation: 'Container'
# Step 2
- stage: Deploy
  displayName: Deploy image
  jobs:
  - job: Deploy
    displayName: Deploy
    pool: SelfPool
    steps:
    # Download artifacts
    - task: DownloadPipelineArtifact@2
      inputs:
        buildType: 'current'
        artifactName: 'manifests'
        itemPattern: '**/*.yml'
        targetPath: '$(System.ArtifactsDirectory)'
    # run again k8s 
    - task: KubernetesManifest@0 
      inputs:
        action: 'deploy'
        kubernetesServiceConnection: 'azure-kubernetes-connection'
        namespace: 'default'
        manifests: '$(System.ArtifactsDirectory)/ci_cd/azure_devops_pipelines/configuration/k8s/deployment.yml'
        containers: 'vyahello/currency-exchange:$(tag)'
```

```bash
# get ip and port and open in browser
kubectl get svc
kubectl get pods
# you should see 'vyahello/currency-exchange:35' image
kubectl get rs -o wide
```

### Destroy Azure Kubernetes Cluster in Azu

```yaml
# terraform destroy part
- task: TerraformCLI@0
  inputs:
    command: 'destroy'
    workingDirectory: '$(System.DefaultWorkingDirectory)/ci_cd/azure_devops_pipelines/configuration/iaac/azure/k8s'
    environmentServiceName: 'azure-resource-manager-service'
```

# AWS EKS with Terraform 

Check [aws](configuration/iaac/aws) folder.

EKS - elastic kubernetes service.

Check terraform module - https://github.com/terraform-aws-modules/terraform-aws-eks.

We will setup 2 pipelines:
  - one to provision a cluster
  - second to do ci/cd and build a docker image and deploy it to kubernetes cluster
  - pipelines will be running in Azure DevOps

Create `terraform-backend-state-vyah` S3 bucket.

We need to make Azure DevOps talk to AWS via `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

## Create Azure DevOps pipeline

Download https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-vsts-tools

Via https://dev.azure.com add "New Service Connection" -> "AWS for Terraform"

```yaml
# 07-aws-k8s-iaac-pipeline.yml

trigger:
- master

pool: SelfPool

steps:
- script: echo Hello, world!
  displayName: 'Run a one-line script'

# terraform task
- task: TerraformTaskV1@0
  inputs:
    provider: 'aws'
    # terraform init command
    command: 'init'
    workingDirectory: '$(System.DefaultWorkingDirectory)/ci_cd/azure_devops_pipelines/configuration/iaac/aws/k8s'
    backendServiceAWS: 'aws-for-terraform'
    backendAWSBucketName: 'terraform-backend-state-vyah'
    backendAWSKey: 'k8s-dev.tfstate'
```

Check pipeline raw logs after run:
```bash
/usr/local/bin/terraform init \ 
  -backend-config=bucket=terraform-backend-state-vyah \
  -backend-config=key=k8s-dev.tfstate \
  -backend-config=region=*** \
  -backend-config=access_key=*** \
  -backend-config=secret_key=***

Terraform has been successfully initialized
```

## Terraform apply to create AWS EKS cluster in Azure DevOps 

```yaml
# terraform apply task
- task: TerraformTaskV1@0
  inputs:
    provider: 'aws'
    # terraform appy command
    command: 'apply'
    workingDirectory: '$(System.DefaultWorkingDirectory)/ci_cd/azure_devops_pipelines/configuration/iaac/aws/k8s'
    environmentServiceName: 'aws-for-terraform'
```

## Deploy to K8S cluster from pipeline

### Install AWS CLI

```bash
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws --version
```

### Create connection to K8S

Get k8s cluster config
```bash
aws configure
...
aws eks --region us-east-1 update-kubeconfig --name=in28minutes-cluster
Added new context arn:aws:eks:us-east-1:708363104337:cluster/in28minutes-cluster to /Users/fox/.kube/config

# we are connected to aws k8s cluster
kubectl version
# our client version
Client Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.5", GitCommit:"c285e781331a3785a7f436042c65c5641ce8a9e9", GitTreeState:"clean", BuildDate:"2022-03-16T15:58:47Z", GoVersion:"go1.17.8", Compiler:"gc", Platform:"darwin/amd64"}
# AWS server version on EKS
Server Version: version.Info{Major:"1", Minor:"21+", GitVersion:"v1.21.5-eks-bc4871b", GitCommit:"5236faf39f1b7a7dabea8df12726f25608131aa9", GitTreeState:"clean", BuildDate:"2021-10-29T23:32:16Z", GoVersion:"go1.16.8", Compiler:"gc", Platform:"linux/amd64"}

kubectl get svc
# get Server URL
kubectl cluster-info
# Server URL, need this to create service connection via Azure
Kubernetes control plane is running at https://473F679F61C5FA04CA3832184008EB91.gr7.us-east-1.eks.amazonaws.com
CoreDNS is running at https://473F679F61C5FA04CA3832184008EB91.gr7.us-east-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

# get "secrets"
kubectl get serviceaccounts default -o yaml
# get secret and copy it from "apiVersion: v1 to end"
kubectl get secret default-token-gjltt -o yaml
```

Go to 'Service connections' -> K8S:
  - Service Account 
  - Service URL: https://473F679F61C5FA04CA3832184008EB91.gr7.us-east-1.eks.amazonaws.com
  - Secret: 
  - Service connection name: aws-k8s-cluster-service

Now you can connect to our K8S cluster from Azure DevOps 

### Create pipeline for deploying microservices to AWS EKS 

Check `08-aws-k8s-code-ci-cd-pipeline.yml` file.

```bash
kubectl get svc

currency-exchange   LoadBalancer   10.100.124.89   a85a95a59ac70478a962b90c2b24b0fb-781103902.us-east-1.elb.amazonaws.com   8000:30137/TCP   3m1
```

Open `a85a95a59ac70478a962b90c2b24b0fb-781103902.us-east-1.elb.amazonaws.com:8000` in browser.

