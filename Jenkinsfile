pipeline {
    agent any
    environment {
        STACK_NAME = "udacity-devops-capstone"
    }
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
        stage('Build EKS cluster') {
            steps {
                sh '''#!/bin/bash
                    make deploy_eks'''
            }
        }
        stage('Update kubernetes config') {
            steps {
                sh 'if [ ! -d /var/lib/jenkins/.kube ]; then mkdir ~/.kube; fi; echo "" > ~/.kube/config && aws eks --region us-east-1 update-kubeconfig --name udacity-devops-capstone'
            }
        }
        stage('Create deployment') {
            steps {
                sh 'kubectl get deployments | grep ${STACK_NAME} || make create_deployment'
	            sh 'kubectl rollout status deployment/${STACK_NAME}'
            }
        }
        stage('Create service') {
            steps {
                sh 'kubectl get services | grep ${STACK_NAME} || make create_service'
                sh 'kubectl describe service ${STACK_NAME}'
            }
        }
    }
}
