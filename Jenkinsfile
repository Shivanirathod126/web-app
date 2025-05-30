pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub') // Replace with Jenkins credentials ID
        IMAGE_NAME = 'shivani446/web-app'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', credentialsId: 'github-pass', url: 'https://github.com/Shivanirathod126/web-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                        docker.image("${IMAGE_NAME}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    kubectl --insecure-skip-tls-verify set image deployment/web-app \
                      YOUR_CONTAINER_NAME=${IMAGE_NAME}:${BUILD_NUMBER} \
                      -n web-app \
                      --kubeconfig /home/ubuntu/kubeconfig
                    """
                }
            }
        }
    }
}

