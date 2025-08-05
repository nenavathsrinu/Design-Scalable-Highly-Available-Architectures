pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'qa', 'stg', 'prod'], description: 'Choose the environment')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action to perform')
        string(name: 'AWS_REGION', defaultValue: 'ap-south-1', description: 'AWS region')
    }

    environment {
        TF_VAR_environment = "${params.ENVIRONMENT}"
        TF_VAR_aws_region  = "${params.AWS_REGION}"
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/nenavathsrinu/Design-Scalable-Highly-Available-Architectures.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${params.AWS_REGION}") {
                    dir("${WORKSPACE}") {
                        bat "terraform init -backend-config=env\\\\${params.ENVIRONMENT}\\\\backend.tfvars"
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when { expression { return params.ACTION == 'plan' } }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${params.AWS_REGION}") {
                    dir("${WORKSPACE}") {
                        bat "terraform plan -var-file=env\\\\${params.ENVIRONMENT}\\\\terraform.tfvars"
                    }
                }
            }
        }

        stage('Terraform Apply Launch Template') {
            when { expression { return params.ACTION == 'apply' } }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${params.AWS_REGION}") {
                    dir("${WORKSPACE}") {
                        bat "terraform apply -auto-approve -target=aws_launch_template.web -var-file=env\\\\${params.ENVIRONMENT}\\\\terraform.tfvars"
                    }
                }
            }
        }

        stage('Terraform Apply Rest of Infrastructure') {
            when { expression { return params.ACTION == 'apply' } }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${params.AWS_REGION}") {
                    dir("${WORKSPACE}") {
                        bat "terraform apply -auto-approve -var-file=env\\\\${params.ENVIRONMENT}\\\\terraform.tfvars"
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when { expression { return params.ACTION == 'destroy' } }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${params.AWS_REGION}") {
                    dir("${WORKSPACE}") {
                        bat "terraform destroy -auto-approve -var-file=env\\\\${params.ENVIRONMENT}\\\\terraform.tfvars"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "✅ Terraform '${params.ACTION}' completed for environment: '${params.ENVIRONMENT}' in region '${params.AWS_REGION}'"
        }
    }
}
