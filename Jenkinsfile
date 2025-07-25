*/*def aws_accounts_id_mapping = [
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


*/

pipeline {
    agent any
    environment {
        CLOUDFLARE_API_TOKEN = credentials("${cloudflare_zone}-cloudflare-token")
        TF_VERSION = "1.12.2"
        TG_VERSION = "0.83.0"
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
        stage('Execute') {
            when {
                expression {
                    JOB_NAME == "build-eks-environment" && params.Action == "apply" && planExitCode == 2
                }
            }
            steps {
                script {
                    input message: "Apply Changes?", submitter: "amit@spekit.co, arajwani, ankit@spekit.co, akalsariya, dipal@spekit.co, dparmar, hemant@spekit.co, hrao, nirav@spekit.co, nkatarmal, jay.kothari@spekit.co, jkothari"
                    def apply_flags
                    if (params.Destroy == true) {
                        def userCause = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause')
                        def buildUser = userCause[0].userId
                        def approvalUser = input message: "Are you sure you want to destroy the ${params.Env} infrastructure? SHOULD NOT BE APPROVED BY PIPELINE STARTER", submitter: "amit@spekit.co, arajwani, ankit@spekit.co, akalsariya, dipal@spekit.co, dparmar, hemant@spekit.co, hrao, nirav@spekit.co, nkatarmal, jay.kothari@spekit.co, jkothari", submitterParameter: "approver"
                        while (buildUser == approvalUser && params.Env != "dev" && params.Env != "staging-failover") {
                            echo 'Pipeline starter should not approve this.'
                            approvalUser = input message: "Are you sure you want to destroy the ${params.Env} infrastructure? SHOULD NOT BE APPROVED BY PIPELINE STARTER", submitter: "amit@spekit.co, arajwani, ankit@spekit.co, akalsariya, dipal@spekit.co, dparmar, hemant@spekit.co, hrao, nirav@spekit.co, nkatarmal, jay.kothari@spekit.co, jkothari", submitterParameter: "approver"
                        }
                        apply_flags = '-destroy'
                    } else {
                        apply_flags = 'tfplan'
                    }
                    maskPasswords() {
                        sh 'docker run --rm' + common_envs + ' \
                            -v $(pwd)/terraform/eks-environments/${Env}:/apps/eks-environments/${Env} \
                            -v $(pwd)/terraform/modules/mod-ekscluster:/apps/modules/mod-ekscluster \
                            -w /apps/eks-environments/${Env} \
                            devopsinfra/docker-terragrunt:aws-tf-${TF_VERSION}-tg-${TG_VERSION} \
                            terragrunt apply -no-color -auto-approve ' + tf_targets + apply_flags + common_tg_cli_args
                    }
                }
            }
        }
        stage('Run Terragrunt Custom Command') {
            when {
                expression {
                    JOB_NAME == "run-custom-terragrunt-command"
                }
            }
            steps {
                script {
                    def cmd = "terragrunt " + params.Command.replace("terragrunt", "").trim()
                    input message: "Are you sure you want to run this command on ${params.Env} environment from ${params.Branch} branch: ${cmd}?", submitter: "amit@spekit.co, arajwani, ankit@spekit.co, akalsariya, dipal@spekit.co, dparmar, hemant@spekit.co, hrao, nirav@spekit.co, nkatarmal, jay.kothari@spekit.co, jkothari"
                    maskPasswords() {
                        sh 'docker run --rm' + common_envs + ' \
                            -v $(pwd)/terraform/eks-environments/${Env}:/apps/eks-environments/${Env} \
                            -v $(pwd)/terraform/modules/mod-ekscluster:/apps/modules/mod-ekscluster \
                            -w /apps/eks-environments/${Env} \
                            devopsinfra/docker-terragrunt:aws-tf-${TF_VERSION}-tg-${TG_VERSION} ' + cmd + common_tg_cli_args
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                stage('Cleanup') {
                    sh 'sudo chown -R jenkins:jenkins $(pwd)'
                }
            }
        }
    }
}
