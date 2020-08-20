RUN = docker-compose run --rm

#Tasks

init:
	$(RUN) terraform init
.PHONY: init

_awsinit:
	mkdir -p creds
	$(RUN) aws configure
.PHONY: _awsinitss

destroy:

.PHONY: destroy

build:
	$(RUN) terraform apply -target module.ecr -var-file="luxx.tfvars" -auto-approve
	bash -x ../scripts/push.sh
.PHONY: build

luxvpc:
	$(RUN) terraform apply -target module.vpc -var-file="luxx.tfvars" -auto-approve

plan:
	$(RUN) terraform plan -var-file="luxx.tfvars" -out=.terraform-plan 
.PHONY: plan

apply:
	$(RUN) terraform apply .terraform-plan 
.PHONY: apply

destroy:
	$(RUN) terraform destroy -var-file="luxx.tfvars" -auto-approve
.PHONY: destroy

all:
	make _awsinit
	make init
	make build
	make plan
	make apply
.PHONY: all