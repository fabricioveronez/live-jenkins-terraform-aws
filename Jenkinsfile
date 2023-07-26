pipeline {
    agent any

    stages {

        stage("Checkout source") {
            steps {
                git url: 'https://github.com/fabricioveronez/live-jenkins-terraform-aws.git', branch: 'main'
                sh 'ls'
            }
        }

        stage('Execução do projeto Terraform') {
            steps {
                script {
                    dir('src') {
                        sh 'terraform init'
                        sh 'terraform apply'
                    }
                }
            }
        }
    }
}
