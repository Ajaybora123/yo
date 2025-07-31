pipeline {
    agent any

    environment {
      AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Ajaybora123/yo.git', branch: 'main'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${env.TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${env.TF_DIR}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${env.TF_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
        }
    }
}
