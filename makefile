AWS_REGION ?=
ENV = dev

initial-setup:
	@echo "By default, this will create the initial AWS resource in:"
	@echo "Environment: dev"
	@echo "AWS region: ap-southeast-2"
	@echo "If you want to change this, use: make initial-setup ENV=somethign AWS_REGION=something"
	@./manual/0_backend.sh $(ENV) $(AWS_REGION)
	@./manual/1_user.sh $(ENV) $(AWS_REGION)

tf-i-d:
	terraform -chdir=dev init

tf-p-d:
	terraform -chdir=dev workspace select -or-create dev
	terraform -chdir=dev plan

tf-a-d:
	terraform -chdir=dev workspace select -or-create dev
	terraform -chdir=dev apply

tf-destroy-d:
	terraform -chdir=dev workspace select -or-create dev
	terraform -chdir=dev destroy
