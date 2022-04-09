// SCRIPTED pipeline
// node runs your pipeline
// node {
// 	echo "Build"
// 	echo "Test"
// 	echo "Test"
// }

// Declarative pipeline
pipeline {
    // declare where your build is going to run, you can use docker image as agent
    // agent any
    agent {
        docker {
            image 'maven:3.6.3'
        }
    }

    environment {
        dockerHome = tool 'myDocker'
        mavenHome = tool 'myMaven'
        PATH = "$dockerHome/bin:$mavenHome/bin:$PATH"
    }

    // add stages, will be run inside docker container
    stages {
        stage('Checkout') {
            steps {
                sh "mvn --version"
                sh "docker --version"
                echo "Build"
                echo "Build Number - $env.BUILD_NUMBER"
                echo "BUILD_ID - $env.BUILD_ID"
                echo "JOB_NAME - $env.JOB_NAME"
                echo "BUILD_TAG - $env.BUILD_TAG"
                echo "BUILD_URL - $env.BUILD_URL"
            }
        }

        stage('Compile') {
            steps {
              dir("ci_cd/jenkins/currency-exchange") {
                  // compile java code, like nmp install, install all dependencies
                  sh "mvn clean compile"
              }
            }
        }

        stage('Test') {
            steps {
                dir("ci_cd/jenkins/currency-exchange") {
                    // run unit tests
                    sh "mvn test"
                }
            }
        }

        stage('Integration Test') {
            // surefire runs unit tests and failsafe runs integration tests in Java
            steps {
	            sh "mvn failsafe:integration-test failsafe:verify"
            }
        }
    }
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
}