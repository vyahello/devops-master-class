# Jenkins 

Allows to create pipelines to run unit/integration tests, code quality check, package your apps. 

Jenkins - CI/CD tool.

## Run as docker image 

https://hub.docker.com/r/jenkins/jenkins

https://github.com/jenkinsci/docker/blob/master/README.md

```bash
docker-compose up
```

- Go to `localhost:8081` and paste a password `ee85af5a404b467bb564eaf755864ccf`.
- Install suggested plugins.
- Create First Admin User. 

## Create Job

- Manage Jenkins -> Global Tool Configuration -> Maven and Docker 
- Create job -> Pipeline -> Poll SCM -> * * * * * (every minute)
- Pipeline -> Pipeline script from SCM -> Git -> https://github.com/vyahello/devops-master-class -> ci_cd/jenkins/currency-exchange/Jenkinsfile (Script Path)
- We have created http://localhost:8081/job/jenkins-devops-pipeline pipeline 
- Click 'Build Now'

## Understand scripted pipelines 

node is a machine that runs your pipeline.

```groovy
// runs your pipeline
node {
	echo "Build"
	echo "Test"
	echo "Integration Test"
}
```