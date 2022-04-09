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
    // add stages, will be run inside docker container
    stages {
        stage('Build') {
            steps {
                sh "mvn --version"
                echo "Build"
                echo "Build Number - $env.BUILD_NUMBER"
                echo "BUILD_ID - $env.BUILD_ID"
                echo "JOB_NAME - $env.JOB_NAME"
                echo "BUILD_TAG - $env.BUILD_TAG"
                echo "BUILD_URL - $env.BUILD_URL"
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