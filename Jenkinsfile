pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Ajaybora123/yo.git'
            }
        }
        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform plan -out tfplan'
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('Terraform Apply') {
            when {
                expression { params.action == 'apply' }
            }
            steps {
                script {
                    if (!params.autoApprove) {
                        def plan = readFile 'tfplan.txt'
                        input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                    }
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
        stage('Terraform Destroy') {
            when {
                expression { params.action == 'destroy' }
            }
            steps {
                script {
                    sh 'terraform destroy --auto-approve'
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
