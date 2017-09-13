APP     = skeleton-node
CLOUD   = gcf # lambda ecs gce gcf heroku digitalocean up docker
PORT    = 3000

# sources
SRC     = $(wildcard *.js)
STATIC  = ./static/

# toolchain
NODE   = /usr/local/bin/node
NPM    = /usr/local/bin/npm
AWS    = /usr/local/bin/aws
GCLOUD = /usr/local/bin/gcloud
HEROKU = /usr/local/bin/heroku
DOCTL  = /usr/local/bin/doctl
DOCKER = /usr/local/bin/docker
GOPATH = $(HOME)/go
UP     = $(GOPATH)/bin/up
GO     = /usr/local/bin/go
BREW   = /usr/local/bin/brew

PROJECT   = $(APP)


# launch service for development (without cloud runtime support)
run: $(NPM) $(NODE) .once-npm-install
	$(NPM) start


# run unit tests then exit
test: $(NODE) .once-npm-install
	# nyi


# launch service locally in a manner similar to deployed
run_local: run_local_$(CLOUD)

run_local_lambda:
	@echo "error: AWS Lambda does not run locally" 1>&2
	@exit 1

run_local_gae:
	@echo "error: Google App Engine does not run node" 1>&2
	@exit 1

run_local_gcf: deps_gcf
	# nyi

run_local_heroku: $(HEROKU) .once-npm-install
	$(HEROKU) local --port $(PORT) web

run_local_ecs run_local_gce run_local_digitalocean run_local_docker: $(DOCKER) build
	# nyi
	# $(DOCKER) ...

run_local_up:
	@echo "error: Up does not run locally (yet)" 1>&2
	@exit 1


# assemble assets for deployment
build build_cloud:
	true


# launch service in the cloud
deploy: deploy_$(CLOUD)
	# nyi

# AWS Lambda
deploy_lambda: $(AWS) .once-init-aws
	# nyi

# Amazon EC2 Container Service
deploy_ecs: $(AWS) .once-init-aws
	# nyi

# Google App Engine
deploy_gae:
	@echo "error: Google App Engine does not run node" 1>&2
	@exit 1

# Google Container Engine
deploy_gce: $(GCLOUD) deps_gce .once-init-gcloud
	# nyi

# Google Cloud Functions
deploy_gcf: $(GCLOUD) deps_gcf .once-init-gcloud
	# nyi

# Heroku Dynos
deploy_heroku: $(HEROKU) .once-init-heroku
	# nyi

# DigitalOcean Droplet (Debian)
deploy_digitalocean: $(DOCTL) .once-init-digitalocean
	# nyi
	# $(DOCTL) compute droplet create name --size 1gb --image image_slug --region nyc1 --ssh-keys ssh_key_fingerprint
	# install systemd
	# start service

deploy_docker:
	@echo "error: Docker is not a cloud; try ecs or gce" 1>&2
	@exit 1

# TJ's Up
deploy_up: $(UP) .once-init-up
	# nyi


# undo "deploy"
revoke: revoke_$(CLOUD)
	# stop service
	# remove instance/app

revoke_lambda: $(AWS) .once-init-aws
	# nyi

revoke_ecs: $(AWS) .once-init-aws
	# nyi

revoke_gae:
	@echo "error: Google App Engine does not run node" 1>&2
	@exit 1

revoke_gce: $(GCLOUD) .once-init-gcloud
	# nyi

revoke_gcf: $(GCLOUD) .once-init-gcloud
	$(GCLOUD) projects delete $(PROJECT)

revoke_heroku: $(HEROKU) .once-init-heroku
	# nyi

revoke_digitalocean: $(DOCTL) .once-init-digitalocean
	# nyi

revoke_docker:
	@echo "error: Docker is not a cloud" 1>&2
	@exit 1

revoke_up: $(UP) .once-init-up
	# nyi


# undo "build"
clean:
	true


# dependencies (tools and sdks)

.once-npm-install: $(NPM)
	$(NPM) install
	touch $@


# cloud dependencies

deps_gce: $(GCLOUD)
	# nyi

deps_gcf: $(GCLOUD)
	$(GCLOUD) components update
	$(GCLOUD) components install beta


# toolchain dependencies

$(NODE) $(NPM): $(BREW)
	$(BREW) install node

$(AWS): $(BREW)
	$(BREW) install awscli

$(GCLOUD): $(BREW)
	$(BREW) install cask google-cloud-sdk

$(HEROKU): $(BREW)
	$(BREW) install heroku

$(DOCTL): $(BREW)
	$(BREW) install doctl

$(DOCKER): $(BREW)
	$(BREW) install docker

$(UP): $(GO)
	$(GO) get github.com/apex/up

$(GO): $(BREW)
	$(BREW) install go

$(BREW):
	/usr/bin/ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# interactively install xcode if missing
# XXX may be moot if "make" or "git" depends on xcode-select
xcode:
	xcode-select --print-path > /dev/null || xcode-select --install


# cloud initialization

.once-init-aws: $(AWS)
	# nyi
	# $(AWS) ...
	touch $@

.once-init-gce: .once-init-gcloud
	# nyi
	# enable GCE api
	touch $@

.once-init-gcf: .once-init-gcloud
	# nyi
	# enable GCF api
	touch $@

.once-init-gcloud: $(GCLOUD)
	$(GCLOUD) --quiet components install app-engine-go
	$(GCLOUD) components install beta
	$(GCLOUD) projects create $(PROJECT)
	$(GCLOUD) beta billing
	$(GCLOUD) init
	touch $@

.once-init-heroku: $(HEROKU)
	# nyi
	touch $@

.once-init-digitalocean: $(DOCTL)
	# nyi
	$(DOCTL) auth init
	touch $@

.once-init-docker: $(DOCKER)
	# nyi
	# $(DOCKER) ...
	touch $@

.once-init-up: $(UP)
	# nyi
	touch $@


.PHONY: run run_local run_local_$(CLOUD)
.PHONY: test
.PHONY: deps_$(CLOUD)
.PHONY: build build_cloud
.PHONY: deploy deploy_$(CLOUD)
.PHONY: revoke revoke_$(CLOUD)
.PHONY: clean

.DEFAULT: run
