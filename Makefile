JEKYLL_IMAGE=jekyll/jekyll
NODE_IMAGE=node:lts

.DEFAULT_GOAL := help

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


##
## Project setup
##---------------------------------------------------------------------------
install:        ## Install dependencies
install:
	docker run --rm --volume="$(PWD):/src" -it $(NODE_IMAGE) bash -c "cd /src && npm install -g gulp && yarn && gulp"
	docker run --rm --volume="$(PWD):/srv/jekyll" -it $(JEKYLL_IMAGE) bundle install

build:          ## Build application
build:
	docker run --rm --volume="$(PWD):/srv/jekyll" -it $(JEKYLL_IMAGE) jekyll build

start:          ## Run development Jekyll server
start:
	docker run --rm --volume="$(PWD):/srv/jekyll" --publish 80:4000 -it $(JEKYLL_IMAGE) jekyll serve

debug:          ## Debug Jekyll server
debug:
	docker run --rm --volume="$(PWD):/srv/jekyll" -it $(JEKYLL_IMAGE) bash


node:           ## Node commands
node:
	docker run --rm --volume="$(PWD):/src" -it $(NODE_IMAGE) bash -c "cd /src && bash"
