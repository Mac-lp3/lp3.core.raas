AWS_REGION ?=
ENV = dev
SESSION_NAME="local-raas-testing"

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

# test runner deployment
# run TF apply
local-test:
	token=$$(aws sts assume-role --role-arn arn:aws:iam::843570803560:role/lp3/core/core-raas-run-role --role-session-name $(SESSION_NAME) --output json --no-cli-pager | jq);\
	export AWS_ACCESS_KEY_ID=$$(echo $$token | jq -r '.Credentials.AccessKeyId');\
	export AWS_SECRET_ACCESS_KEY=$$(echo $$token | jq -r '.Credentials.SecretAccessKey');\
	export AWS_SESSION_TOKEN=$$(echo $$token | jq -r '.Credentials.SessionToken');\
	terraform -chdir=dev workspace select -or-create dev;\
	terraform -chdir=dev init;\
	terraform -chdir=dev apply