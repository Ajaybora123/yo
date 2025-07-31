pipeline {
    agent any

 environment {
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
}

    

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Ajaybora123/yo.git', branch: 'main'
            }
        }

        stage('Terraform Init') {
            
                
                    sh 'terraform init'
            
            
        }

        stage('Terraform Plan') {
            
                    sh 'terraform plan -out=tfplan'
                
            
        }

        stage('Terraform Apply') {
          
                
                    sh 'terraform apply -auto-approve tfplan'
                
            
        }
    }

    post {
        always {
            echo 'Cleaning up...'
        }
    }
}
