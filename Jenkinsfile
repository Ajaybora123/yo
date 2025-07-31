pipeline {
    agent any

 
    

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Ajaybora123/yo.git', branch: 'main'
            }
        }

        stage('Terraform Init') {
            steps {
                {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                 {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                {
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
