RUN = docker-compose run --rm

#Tasks

init:
	$(RUN) terraform init
.PHONY: init

_awsinit:
	mkdir -p creds
	$(RUN) aws configure
.PHONY: _awsinit

destroy:

.PHONY: destroy