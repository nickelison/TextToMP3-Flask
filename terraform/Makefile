SHELL := /usr/bin/env bash
PROJECT_DIR := $(shell dirname "$(shell pwd)")

# COLORS
RED=$(shell echo -e "\033[0;31m")
GRE=$(shell echo -e "\033[0;32m")
NC=$(shell echo -e "\033[0m")

# TERRAFORM INSTALL
version  ?= "1.0.10"
os       ?= $(shell uname|tr A-Z a-z)
ifeq ($(shell uname -m),x86_64)
    arch   ?= "amd64"
endif
ifeq ($(shell uname -m),i686)
    arch   ?= "386"
endif
ifeq ($(shell uname -m),aarch64)
    arch   ?= "arm"
endif

# CHECK TERRAFORM VERSION
TERRAFORM := $(shell command -v terraform 2> /dev/null)
ECR_REPO_NAME := flask-demo-ecr-repo
AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query "Account" --output text)
REGION := $(shell aws configure get region)


aws-info:
	@echo "$(AWS_ACCOUNT_ID)"
	@echo "$(AWS_ACCESS_KEY_ID)"

deploy-infra:
	@terraform init
	@echo "$(GRE)INFO: Deploying Terraform resources.$(NC)"
	@terraform fmt -recursive && \
	 terraform validate && \
	 terraform apply -auto-approve
	@aws ec2 describe-instances --filters "Name=tag:ProjectASG,Values=project-instance" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].{PublicDnsName: PublicDnsName, Region: Placement.AvailabilityZone}' --output table

update-infra:
	@echo "$(GRE)INFO: Updating Terraform resources.$(NC)"
	@terraform init -reconfigure && \
     terraform validate && \
     terraform apply -auto-approve

destroy-infra:
	@echo "$(RED)INFO: Removing all Terraform created resources$(NC)"
	@terraform init -reconfigure && \
	 terraform validate && \
	 terraform destroy -auto-approve
	@echo "$(RED)INFO: Removing local build artifacts.$(NC)"
	@rm -rf .terraform* terraform.tfs*

ecr-deploy:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 431608762876.dkr.ecr.us-east-1.amazonaws.com
	cd "$(PROJECT_DIR)" && \
	docker buildx build --platform=linux/amd64 --file Dockerfile -t $(ECR_REPO_NAME) --build-arg AWS_ACCESS_KEY_ID="$(AWS_ACCESS_KEY_ID)" --build-arg AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" --build-arg AWS_DEFAULT_REGION="$(AWS_DEFAULT_REGION)" . && \
	docker tag $(ECR_REPO_NAME):latest $(AWS_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/$(ECR_REPO_NAME):latest && \
	docker push 431608762876.dkr.ecr.us-east-1.amazonaws.com/$(ECR_REPO_NAME):latest

ecr-update:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 431608762876.dkr.ecr.us-east-1.amazonaws.com
	cd "$(PROJECT_DIR)" && \
	docker buildx build --platform=linux/amd64 --file Dockerfile -t $(ECR_REPO_NAME) --build-arg AWS_ACCESS_KEY_ID="$(AWS_ACCESS_KEY_ID)" --build-arg AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" --build-arg AWS_DEFAULT_REGION="$(AWS_DEFAULT_REGION)" . && \
	docker tag $(ECR_REPO_NAME):latest $(AWS_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/$(ECR_REPO_NAME):latest && \
	docker push 431608762876.dkr.ecr.us-east-1.amazonaws.com/$(ECR_REPO_NAME):latest
	@aws ecs update-service --cluster demo-ecs-cluster --service demo-flask-service --force-new-deployment --region us-east-1

update-ssh-config:
	$(eval BASTION_PUBLIC_DNS := $(shell aws ec2 describe-instances --filters 'Name=instance-type,Values=t2.micro' 'Name=key-name,Values=AWSTest' 'Name=availability-zone,Values=us-east-1a' --query 'Reservations[].Instances[].[PublicDnsName]' --output text))
	$(eval INSTANCE_A_PUBLIC_DNS := $(shell aws ec2 describe-instances --filters 'Name=instance-type,Values=t2.medium' 'Name=key-name,Values=AWSTest' 'Name=availability-zone,Values=us-east-1a' --query 'Reservations[].Instances[].[PublicDnsName]' --output text))
	$(eval INSTANCE_B_PUBLIC_DNS := $(shell aws ec2 describe-instances --filters 'Name=instance-type,Values=t2.medium' 'Name=key-name,Values=AWSTest' 'Name=availability-zone,Values=us-east-1e' --query 'Reservations[].Instances[].[PublicDnsName]' --output text))
	@echo "Updating ~/.ssh/config"
	@sed -i.bak '/^Host project-bastion-instance/,+1s/HostName.*/HostName $(BASTION_PUBLIC_DNS)/' ~/.ssh/config
	@sed -i.bak '/^Host project-private-instance-a/,+1s/HostName.*/HostName $(INSTANCE_A_PUBLIC_DNS)/' ~/.ssh/config
	@sed -i.bak '/^Host project-private-instance-b/,+1s/HostName.*/HostName $(INSTANCE_B_PUBLIC_DNS)/' ~/.ssh/config
	@rm -f ~/.ssh/config.bak
