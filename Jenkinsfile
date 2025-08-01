pipeline {
    agent any

    environment {
        // Optional: If you're using AWS
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git ''
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Do you want to apply the changes?"
                sh 'terraform apply tfplan'
            }
        }
    }

    post {
        always {
            echo 'Pipeline Finished.'
        }
    }
}
