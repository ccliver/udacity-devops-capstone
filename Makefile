.DEFAULT_GOAL := help

REGION="us-east-1"
MY_IP=$(shell curl -s https://ifconfig.me)
STACK_NAME="udacity-devops-capstone"
DOCKER_OPTIONS := -v ${PWD}:/work \
-w /work \
-it \
-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
-e MY_IP=${MY_IP}
CLI_OPTS := --region ${REGION} \
--stack-name ${STACK_NAME} \
--capabilities CAPABILITY_IAM \
--template-body file:///work/cloudformation/jenkins.yml \
--parameters ParameterKey=JenkinsAllowedIP,ParameterValue=${MY_IP} \
  ParameterKey=InstanceType,ParameterValue=t2.medium \
  ParameterKey=AMI,ParameterValue=ami-0dba2cb6798deb6d8

generate_jenkins_ssh_key: ## Create an SSH key to get on the Jenkins instance
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws ec2 create-key-pair --region ${REGION} --key-name jenkins-key | jq -r .KeyMaterial > id_rsa
	@chmod 400 id_rsa

build_stack: ## Deploy Jenkins
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation create-stack ${CLI_OPTS}

update_stack: ## Update Jenkins stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation update-stack ${CLI_OPTS}

show_stacks: ## Show deployed stacks
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation describe-stacks --region ${REGION}

delete_jenkins: ## Delete the infrastructure stack
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation delete-stack \
	--stack-name ${STACK_NAME} --region ${REGION}

validate_template: ## Validate template syntax
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws cloudformation validate-template \
	--region ${REGION} --template-body file:///work/cloudformation/jenkins.yml

ssh_jenkins: ## SSH to the Jenkins instance
	@ssh -i id_rsa ubuntu@$(shell aws cloudformation describe-stacks --stack-name ${STACK_NAME} | jq -r .Stacks[0].Outputs[0].OutputValue)

jenkins_url: ## Output URL to Jenkins
	@echo "http://$(shell aws cloudformation describe-stacks --stack-name ${STACK_NAME} | jq -r .Stacks[0].Outputs[0].OutputValue):8080"

deploy_eks: ## Deploy an EKS cluster with eksctl
	@eksctl get cluster ${STACK_NAME} --region ${REGION} || \
		eksctl create cluster --name ${STACK_NAME} --version 1.17 --region ${REGION} \
		--nodegroup-name linux-nodes --nodes 3 --nodes-min 1 --nodes-max 4 --managed

destroy_eks: ## Destroy an EKS cluster with eksctl
	@eksctl delete cluster --name ${STACK_NAME} --region ${REGION}

lint: ## Check Dockerfile and html for syntax errors
	@docker run --rm -i hadolint/hadolint < Dockerfile
	@tidy -q -e html/index.html

build_app: ## Build app docker image
	@docker build . -t ${STACK_NAME}
	@aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 420711152239.dkr.ecr.us-east-1.amazonaws.com
	@docker tag ${STACK_NAME}:latest 420711152239.dkr.ecr.us-east-1.amazonaws.com/${STACK_NAME}:latest
	@docker push 420711152239.dkr.ecr.us-east-1.amazonaws.com/${STACK_NAME}:latest

create_deployment: ## Create a Kubernetes deployment for the app
	@kubectl apply -f deployment.yml

create_service: ## Create the Kubernetes service and load balancer
	@kubectl apply -f service.yml

deploy_latest_app: ## Deploy the latest version of the app
	@kubectl set image deployment ${STACK_NAME} ${STACK_NAME}=420711152239.dkr.ecr.us-east-1.amazonaws.com/udacity-devops-capstone:latest
	@kubectl rollout status -w deployment ${STACK_NAME}

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
