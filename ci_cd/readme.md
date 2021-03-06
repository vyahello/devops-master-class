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

[Jenkins](jenkins) and [Azure DevOps](azure_devops_pipelines).

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
