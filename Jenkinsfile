pipeline {
    agent any
    stages {
        stage('Lint Dockerfile and HTML') {
            steps {
                sh 'make lint'
            }
        }
        stage('Build app') {
            steps {
                sh 'make build_app'
            }
        }
        stage('Update kubernetes config') {
            steps {
                sh 'if [ ! -d /var/lib/jenkins/.kube ]; then mkdir ~/.kube; fi; echo "" > ~/.kube/config && aws eks --region us-east-1 update-kubeconfig --name udacity-devops-capstone'
            }
        }
        /*stage('Deploy App') {
            steps {
                sh 'make deploy_latest_app'
            }
        }*/
    }
}
