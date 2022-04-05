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
- Check pipeline config: [azure-pipelines.yml](azure_devops_pipelines/azure-pipelines.yml)
- Check job result via https://dev.azure.com/vjagello93/azure-devops-kuber-terra/_build
