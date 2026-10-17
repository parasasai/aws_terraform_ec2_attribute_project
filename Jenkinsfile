pipeline {
    agent any

    environment {
        // Unpacks the single AWS Credentials block you saved under 'aws-credentials-id'
        AWS_CREDENTIALS       = credentials('aws-credentials-id')
        AWS_ACCESS_KEY_ID     = env.AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY = env.AWS_SECRET_ACCESS_KEY
        TF_IN_AUTOMATION      = 'true'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Approval Gate') {
            steps {
                input message: "Do you want to deploy this infrastructure to AWS?", ok: "Deploy Now"
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            // Wrapped in a node block to prevent the ' h_udson.FilePath is missing' exception
            node {
                cleanWs()
            }
        }
    }
}
