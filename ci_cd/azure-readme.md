# Continuous Integration

CI - to get quick feedback when you commit some code to the repository. Find problems early.

Code commit -> Code quality -> -> Unit tests -> Package -> Integration tests

# Continuous Deployment

Includes an additional step: deploy the package into environment (dev/qa) and run few automated tests (smoke, etc.)

Code commit -> Code quality -> Unit tests -> Integration tests -> Package -> Deploy app -> Automated tests

# Continuous Delivery

Along with packaging and deployment and running smoke tests, you setup a pipeline to automatically deploy app to a production environment.

If QA team gives the approval, then code will be automatically deployed on to stage and prod env.

Deploy app automatically to different environments.

Code commit -> Code quality  -> Unit tests -> Integration tests -> Package -> Deploy app to stage -> Automated tests -> Testing Approval -> Deploy prod to next env -> ...

# Tools 

Jenkins and Azure devops.

We need to create CI/CD pipelines.

CD in depth:
  - Code commit (in github)
  - Unit tests (pytest, moka, jasmine, junit)
  - Integration tests (selenium, cucumber, protractor). Write auto tests of few modules integrated together.
  - Package (build deployable unit of app). Used npm, pip, maven.
  - Deploy to env (via Jenkins, Azure DevOps)
  - Run Additional tests (smoke, functional, performance tests)
  - Once auto/manual tests are fine, you go and approve
  - Deploy app on the next env. If you approve on qa, then app will be deployed on stage env

## Azure devops 

Allows continuous integration, deployment and delivery of software.

Create Azure account and go to https://portal.azure.com 

Go to https://dev.azure.com

### Create Azure devops project 

https://dev.azure.com/vjagello93/azure-devops-kuber-terra

- Go to pipelines and select github repo 
- Create YAML pipeline. In case of pool issues you need to configure self-hosted pool via https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-osx?view=azure-devops
- Click run and commit the pipeline 
- Check pipeline config: [azure-pipelines.yml](azure_devops_pipelines/pipelines/01-azure-pipelines-jobs.yml)
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

Check config in [keys](azure_devops_pipelines/configuration/iaac/azure/k8s/.keys) file:
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