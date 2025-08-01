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
if (!params.Env || !aws_accounts_id_mapping.containsKey(params.Env)) {
def cloudflare_zone = cloudflare_env_mapping[params.Env]
if (cloudflare_zone == null) {
    error("Invalid or missing Env parameter: '${params.Env}'. Please provide a valid environment.")
}
}
def aws_account_id = aws_accounts_id_mapping[params.Env]
def common_envs = " -e CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN}"
def planExitCode
def tf_targets = ""
def common_envs = ' -e CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN}'
def common_tg_cli_args = " --iam-assume-role arn:aws:iam::${aws_account_id}:role/terraform --backend-bootstrap"

// Helper function to build terragrunt docker command
def buildTerragruntCommand(Map args) {
    return """
        docker run --rm${args.commonEnvs} \
        -v \$(pwd)/terraform/eks-environments/${Env}:/apps/eks-environments/${Env} \
        -v \$(pwd)/terraform/modules/mod-ekscluster:/apps/modules/mod-ekscluster \
        -w /apps/eks-environments/${Env} \
        devopsinfra/docker-terragrunt:aws-tf-${TF_VERSION}-tg-${TG_VERSION} \
        terragrunt ${args.action} ${args.tfTargets}${args.planFlags} -no-color -detailed-exitcode${args.commonTgCliArgs}
    """.stripIndent().trim()
}

pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
                    if (params.Targets && params.Targets.trim()) {
                        tf_targets = params.Targets.trim()
                        common_envs += """
                         -e AWS_ACCESS_KEY_ID=${AWSAccessKeyID} \
                         -e AWS_SECRET_ACCESS_KEY=${AWSSecretAccessKey} \
                         -e AWS_SESSION_TOKEN=${AWSSessionToken}
                        """
                        common_tg_cli_args = ""
                    } else {
                        tf_targets = ' '
                    }
                        error("Please use main branch to run terragrunt for ${params.Env} environment")
                    }
                    if (params.Targets) {
                                                common_envs += """
                         -e AWS_ACCESS_KEY_ID=${AWSAccessKeyID} \
                         -e AWS_SECRET_ACCESS_KEY=${AWSSecretAccessKey} \
                         -e AWS_SESSION_TOKEN=${AWSSessionToken}
                        """
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
                    maskPasswords() {
                        def terragruntPlanCommand = buildTerragruntCommand(
                            action: "plan",
                            planFlags: plan_flags,
                            tfTargets: tf_targets,
                            commonEnvs: common_envs,
                            commonTgCliArgs: common_tg_cli_args
                        )
                        planExitCode = sh (
                            script: terragruntPlanCommand,
                            returnStatus: true
                        )
                    }
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
                            script: "docker run --rm${common_envs} \
                                -v \$(pwd)/terraform/eks-environments/${Env}:/apps/eks-environments/${Env} \
                                -v \$(pwd)/terraform/modules/mod-ekscluster:/apps/modules/mod-ekscluster \
                                -w /apps/eks-environments/${Env} \
                                devopsinfra/docker-terragrunt:aws-tf-${TF_VERSION}-tg-${TG_VERSION} \
                                terragrunt apply ${tf_targets}-auto-approve -no-color${common_tg_cli_args}",
                            returnStatus: true
                        )
                    }
                }
            }
        }
        stage('Destroy') {
            when {
                expression {
                    JOB_NAME == "build-eks-environment" && params.Destroy == true
                }
            }
            steps {
                script {
                    maskPasswords() {
                        sh (
                            script: "docker run --rm${common_envs} \
                                -v \$(pwd)/terraform/eks-environments/${Env}:/apps/eks-environments/${Env} \
                                -v \$(pwd)/terraform/modules/mod-ekscluster:/apps/modules/mod-ekscluster \
                                -w /apps/eks-environments/${Env} \
                                devopsinfra/docker-terragrunt:aws-tf-${TF_VERSION}-tg-${TG_VERSION} \
                                terragrunt destroy ${tf_targets}-auto-approve -no-color${common_tg_cli_args}",
                            returnStatus: true
                        )
                    }
                }
            }
        }
        stage('Post Actions') {
            steps {
                script {
                    if (currentBuild.result == 'FAILURE') {
                        echo "Pipeline failed. Sending notification..."
                        // Add notification logic here (e.g., email, Slack)
                    } else {
                        echo "Pipeline completed successfully."
                    }
                }
            }
        }
    }
}
