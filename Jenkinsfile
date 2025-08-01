pipeline {
    agent any

 environment {
    // Ensure that the Jenkins credential 'aws-access-key-id' is configured in your Jenkins instance.
    // Ensure 'aws-secret-access-key' is set up in Jenkins credentials for this to work
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
}
    stages {
    stage('Terraform') {
        steps {
            script {
                    dir('Terraform') {
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh "terraform ${params.ACTION} -auto-approve"
                        if (params.ACTION == 'apply') {
                        sh "terraform ${params.ACTION} -auto-approve"
                        def ip_address = sh(script: 'terraform output public_ip', returnStdout: true).trim()
                        writeFile file: '../Ansible/inventory', text: "monitoring-server ansible_host=${ip_address}"
                        }
                    }
            }
        }
    }
    }
}
