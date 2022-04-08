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
//             image 'python:3.9'
        }
    }
    // add stages, will be run inside docker container
    stages {
        stage('Build') {
            steps {
                sh "mvn --version"
//                 sh 'python --version'
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