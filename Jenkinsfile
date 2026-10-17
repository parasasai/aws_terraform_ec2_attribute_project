pipeline {
    agent any

    environment {
        // Safe mapping of the Jenkins global credentials store directly into host memory
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        
        // Tells Terraform to suppress interactive terminal prompts since it's running via automation
        TF_IN_AUTOMATION      = 'true'
    }

    stages {
        stage('Workspace Diagnostic') {
            steps {
                echo "=== Debugging Local Environment ==="
                sh 'whoami'
                sh 'terraform --version'
            }
        }

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                // Initializes the local working directory and checks the remote S3 backend
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                // Generates an explicit deployment plan file saved locally on the host path
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Approval Gate') {
            steps {
                // Pauses execution and waits for your confirmation in the Jenkins UI
                input message: "Do you want to apply this infrastructure plan to AWS?", ok: "Deploy Now"
            }
        }

        stage('Terraform Apply') {
            steps {
                // Targets the generated plan file directly for an instant, safe update execution
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            // Wipes the transient git clones from the Jenkins host directories to maintain disk space health
            cleanWs()
        }
    }
}
