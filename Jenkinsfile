def aws_accounts_id_mapping = [
    "dev": "283819745154",
    "devops-sandbox": "283819745154",
    "staging": "768619733044",
    "staging-failover": "202047904840",
    "production": "021140579868",
    "production-failover": "274509955377",
    "infra-core": "672576756280"
]
def cloudflare_env_mapping = [
    "dev": "spekit-dev",
    "devops-sandbox": "spekit-dev",
    "staging": "spektacular-ninja",
    "staging-failover": "spektacular-ninja",
    "production": "spekit-co",
    "production-failover": "spekit-co",
    "infra-core": "spekit-dev"
]
def aws_account_id = aws_accounts_id_mapping[params.Env]
def cloudflare_zone = cloudflare_env_mapping[params.Env]
def planExitCode
def tf_targets = ""
def common_envs = ' -e CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN}'
def common_tg_cli_args = " --iam-assume-role arn:aws:iam::${aws_account_id}:role/terraform --backend-bootstrap"



pipeline {
    agent any
    environment {
           AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_REGION = 'us-east-2'
    }
    stages {
        stage('Init') {
            steps {
                script {
                    if ((params.Env == "production" || params.Env == "production-failover" || params.Env == "infra-core") && params.Branch != "main" && (params.Action == null || params.Action == "apply")) {
                        currentBuild.result = 'FAILURE'
                        error("Please use main branch to run terragrunt for ${params.Env} environment")
                    }
                    if (params.Targets) {
                        tf_targets = params.Targets.split(/[\s,]+/).collect { it.trim() }.collect { "-target ${it}" }.join(' ') + ' '
                    }
                    if (params.Env == "production-failover") {
                        common_envs = common_envs + ' -e AWS_ACCESS_KEY_ID=${AWSAccessKeyID} \
                            -e AWS_SECRET_ACCESS_KEY=${AWSSecretAccessKey} \
                            -e AWS_SESSION_TOKEN=${AWSSessionToken}'
                        common_tg_cli_args = ""
                    }
                }
            }
        }
        stage('Plan') {
            when {
                expression {
                    JOB_NAME == "build-eks-environment"
                }
            }
            steps {
                script {
                    def plan_flags
                    if (params.Destroy == true) {
                        plan_flags = '-destroy'
                    } else {
                        plan_flags = '-out=tfplan'
                    }
                    maskPasswords() {
                        planExitCode = sh (
                            script: 'docker run --rm' + common_envs + ' \
                                -v $(pwd)/terraform/eks-environments/${Env}:/apps/eks-environments/${Env} \
                                -v $(pwd)/terraform/modules/mod-ekscluster:/apps/modules/mod-ekscluster \
                                -w /apps/eks-environments/${Env} \
                                devopsinfra/docker-terragrunt:aws-tf-${TF_VERSION}-tg-${TG_VERSION} \
                                terragrunt plan ' + tf_targets + plan_flags + ' -no-color -detailed-exitcode' + common_tg_cli_args,
                            returnStatus: true
                        )
                    }
                    if (planExitCode == 1) {
                        currentBuild.result = 'FAILURE'
                        error("Error in running terraform plan. Terminating the pipeline.")
                    }
                }
            }
        }

        stage('Apply') {
            when {
                expression {
                    JOB_NAME == "build-eks-environment" && (params.Action == null || params.Action == "apply")
                }
            }
            steps {
                script {
                    maskPasswords() {
                        sh (
                            script: 'docker run --rm' + common_envs + ' \
                                -v $(pwd)/terraform/eks-environments/${Env}:/apps/eks-environments/${Env} \
                                -v $(pwd)/terraform/modules/mod-ekscluster:/apps/modules/mod-ekscluster \
                                -w /apps/eks-environments/${Env} \
                                devopsinfra/docker-terragrunt:aws-tf-${TF_VERSION}-tg-${TG_VERSION} \
                                terragrunt apply ' + tf_targets + '-auto-approve -no-color' + common_tg_cli_args,
                            returnStatus: true
                        )
                    }
                }
            }
        
        stage('Destroy') {
            when {
                expression {
                    JOB_NAME == "build-eks-environment" && params.Destroy == true
                }
            }
    }
}
