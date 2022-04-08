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