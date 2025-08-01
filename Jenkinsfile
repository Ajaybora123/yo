pipeline {
    agent any

    
    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Ajaybora123/yo.git'
            }
        }
    }

        stage('Terraform Init') {
            steps {
              withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ])
            {
                sh 'terraform init'
            }
        }
        }

        stage('Terraform Plan') {
            steps{
              withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]){
                sh 'terraform plan -out=tfplan'
            }
        }
        }

        stage('Terraform Apply') {
            steps {
                  withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ])
                {
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
