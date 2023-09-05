AWS_REGION ?=
ENV = dev
SESSION_NAME="local-raas-testing"
ROLE_ARN="arn:aws:iam::843570803560:role/lp3/core/core-raas-run-role"

initial-setup:
	@echo "By default, this will create the initial AWS resource in:"
	@echo "Environment: dev"
	@echo "AWS region: ap-southeast-2"
	@echo "If you want to change this, use: make initial-setup ENV=somethign AWS_REGION=something"
	@./manual/0_backend.sh $(ENV) $(AWS_REGION)
	@./manual/1_user.sh $(ENV) $(AWS_REGION)

initial-setup-prod:
	@echo "By default, this will create the initial AWS resource in:"
	@echo "Environment: production"
	@echo "AWS region: ap-southeast-2"
	@echo "If you want to change this, use: make initial-setup ENV=somethign AWS_REGION=something"
	@./manual/0_backend.sh prod $(AWS_REGION)
	@./manual/1_user.sh prod $(AWS_REGION)

tf-i-dev:
	terraform -chdir=dev init
	terraform -chdir=dev workspace new local-dev

tf-i-prod:
	terraform -chdir=prod init
	terraform -chdir=prod workspace new local-main

tf-i-branch:
	terraform -chdir=prod init
	terraform -chdir=prod workspace select local-main
	terraform -chdir=prod state pull > prod/main.tfstate
	terraform -chdir=prod workspace new branch
	terraform -chdir=prod state push main.tfstate
	rm prod/main.tfstate

tf-p-d:
	terraform -chdir=dev workspace select local-dev
	terraform -chdir=dev plan

tf-p-prod:
	terraform -chdir=prod workspace select local-main
	terraform -chdir=prod plan

tf-p-branch:
	terraform -chdir=prod workspace select branch
	terraform -chdir=prod plan

tf-a-d:
	terraform -chdir=dev workspace select local-dev
	terraform -chdir=dev apply

tf-a-prod:
	terraform -chdir=prod workspace select local-main
	terraform -chdir=prod apply

tf-a-branch:
	terraform -chdir=prod workspace select branch
	terraform -chdir=prod apply

tf-destroy-d:
	terraform -chdir=dev workspace select local-dev
	terraform -chdir=dev destroy

tf-destroy-prod:
	terraform -chdir=prod workspace select local-main
	terraform -chdir=prod destroy

tf-destroy-branch:
	terraform -chdir=prod workspace select branch
	terraform -chdir=prod destroy

tf-list-prod:
	terraform -chdir=prod workspace select local-main
	terraform -chdir=prod state list

tf-list-branch:
	terraform -chdir=prod workspace select branch
	terraform -chdir=prod state list

tf-del-branch:
	terraform -chdir=prod workspace select local-main
	terraform -chdir=prod workspace delete branch

tf-merge:
	terraform -chdir=prod workspace select local-main
	terraform -chdir=prod state pull > main.tfstate
	terraform state list -state=main.tfstate > main-resources.txt
	terraform -chdir=prod workspace select branch
	terraform -chdir=prod state pull > branch.tfstate
	terraform state list -state=branch.tfstate > branch-resources.txt
	diff main-resources.txt branch-resources.txt | grep '^>' | cut -c 3- | sed 's/"/\\"/g' | xargs -I %s terraform state mv -state=branch.tfstate -state-out=main.tfstate %s %s
	jq '.serial += 1' main.tfstate > main.tfstate.tmp
	mv main.tfstate.tmp prod/main.tfstate
	terraform -chdir=prod workspace select local-main
	terraform -chdir=prod state push main.tfstate
	rm prod/main.tfstate main.tfstate* main-resources.txt branch-resources.txt branch.tfstate*

sts:
	token=$$(aws sts assume-role --role-arn $(ROLE_ARN) --role-session-name $(SESSION_NAME) --duration-seconds 900 --output json --no-cli-pager | jq);\
	export AWS_ACCESS_KEY_ID=$$(echo $$token | jq -r '.Credentials.AccessKeyId');\
	export AWS_SECRET_ACCESS_KEY=$$(echo $$token | jq -r '.Credentials.SecretAccessKey');\
	export AWS_SESSION_TOKEN=$$(echo $$token | jq -r '.Credentials.SessionToken');\
	aws sts get-caller-identity

local-test:
	token=$$(aws sts assume-role --role-arn $(ROLE_ARN) --role-session-name $(SESSION_NAME) --duration-seconds 900 --output json --no-cli-pager | jq);\
	export AWS_ACCESS_KEY_ID=$$(echo $$token | jq -r '.Credentials.AccessKeyId');\
	export AWS_SECRET_ACCESS_KEY=$$(echo $$token | jq -r '.Credentials.SecretAccessKey');\
	export AWS_SESSION_TOKEN=$$(echo $$token | jq -r '.Credentials.SessionToken');\
	terraform -chdir=dev workspace select local-dev;\
	terraform -chdir=dev init;\
	terraform -chdir=dev apply