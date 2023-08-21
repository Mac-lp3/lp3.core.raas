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