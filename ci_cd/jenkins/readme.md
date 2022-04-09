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
- Create job -> Pipeline -> Poll SCM -> * * * * * (every minute will check if there are changes and run)
- Pipeline -> Pipeline script from SCM -> Git -> https://github.com/vyahello/devops-master-class -> ci_cd/jenkins/currency-exchange/Jenkinsfile.groovy (Script Path)
- We have created http://localhost:8081/job/jenkins-devops-pipeline pipeline 
- Click 'Build Now'

## Understand scripted pipelines 

node is a machine that runs your pipeline.

```groovy
// Scripted pipeline
// runs your pipeline
node {
	echo "Build"
	echo "Test"
	echo "Integration Test"
}
```

## Understand declarative pipelines 

```groovy
// Declarative pipeline
pipeline {
    // declare where your build is going to run, you can use docker image as agent
    agent any
    // add stages
    stages {
        stage('Build') {
            steps {
                echo "Build"
            }
        }
        stage('Test') {
            steps {
	            echo "Test"
            }
        }
        stage('Integration Test') {
            steps {
	            echo "Integration Test"
            }
        }
    }
}
```

Add post action
```groovy
    // action to execute after all stages
    post {
        always {
            echo "Always run"
        }
        success {
            echo "Run when you are successful"
        }
        failure {
            echo "Run when you are fail"
        }
    }
```

## Add Jenkins build inside docker container

```groovy
    agent {
        docker {
            image 'maven:3.6.3'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh "mvn --version"
                echo "Build"
            }
        }
```


## Pipeline syntax 

https://www.jenkins.io/doc/book/pipeline/

Use Jenkins `Pipeline Syntax` feature.

For example to checkout code in pipeline: 
```groovy
checkout(
  [$class: 'GitSCM', 
  branches: [[name: '*/master']], 
  extensions: [], 
  userRemoteConfigs: 
  [[url: 'https://github.com/vyahello/devops-master-class']]]
)
```

Retry 5 times 
```groovy
retry(5) {
    // some block
}
```

## Pipeline with docker and maven 

```groovy
    environment {
        dockerHome = tool 'myDocker'
        mavenHome = tool 'myMaven'
        PATH = "$dockerHome/bin:$mavenHome/bin:$PATH"
    
```


## Run unit/integration tests in Jenkins pipeline 

Check `pom.xml` file as a dependency file. 

`surefire` is for unit tests and `failsafe` is for integration tests.
```xml
<surefire.version>2.22.1</surefire.version>
<failsafe.version>2.22.1</failsafe.version>
```

```xml 
<groupId>org.apache.maven.plugins</groupId>
<artifactId>maven-failsafe-plugin</artifactId>
<version>${failsafe.version}</version>
```

## Build and push docker image 

Give Jenkins docker creds via `Credentials` -> `Global Credentials` -> `Add Credentials` and store as `dockerHub`.

```groovy 
        stage('Build Docker image') {
            steps {
                // docker build -t vyahello/currency-exchange:$env.BUILD_TAG
                script {
                    dockerImage = docker.build('vyahello/currency-exchange:${env.BUILD_TAG}')
                }
            }
        }
        stage('Push Docker image') {
            steps {
                script {
                    // used from credentials
                    docker.withRegistry('', 'dockerHub') {
                        dockerImage.push();
                        dockerImage.push('latest');
                    }
                }
            }
        }
```
