pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-creds') // Replace with Jenkins credentials ID
        IMAGE_NAME = 'shivani446/web-app'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git credentialsId: 'github-creds-id', url: 'https://github.com/Shivanirathod126/web-app.git'
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
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-creds') {
                        docker.image("${IMAGE_NAME}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }

        Uncomment this stage if you're ready to deploy
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    kubectl set image deployment/your-deployment-name your-container-name=${IMAGE_NAME}:${BUILD_NUMBER} --kubeconfig=/path/to/kubeconfig
                    """
                }
            }
        }
    }
}
