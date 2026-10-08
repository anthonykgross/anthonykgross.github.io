JEKYLL_IMAGE=jekyll/jekyll:4.2.2
NODE_IMAGE=node:lts

.DEFAULT_GOAL := help

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


##
## Project setup
##---------------------------------------------------------------------------
install:        ## Install dependencies
install:
	docker run --rm --volume="$(PWD):/src" -it $(NODE_IMAGE) bash -c "cd /src && yarn"
	docker run --rm --volume="$(PWD):/srv/jekyll" -it $(JEKYLL_IMAGE) bundle install

build:          ## Build application
build:
	docker run --rm --volume="$(PWD):/srv/jekyll" -it $(JEKYLL_IMAGE) jekyll build

build-prod:     ## Build with the production config only, exactly like CI
build-prod:
	docker run --rm --volume="$(PWD):/srv/jekyll" --env JEKYLL_ENV=production $(JEKYLL_IMAGE) jekyll build --config _config_prod.yml

check:          ## Build like CI, then check JSON-LD, robots, sitemap and Markdown views
check: build-prod
	docker run --rm --volume="$(PWD):/srv/jekyll" $(JEKYLL_IMAGE) ruby /srv/jekyll/bin/check-machine-views.rb

start:          ## Run development Jekyll server
start:
	docker run --rm --volume="$(PWD):/srv/jekyll" --publish 81:4000 -it $(JEKYLL_IMAGE) jekyll serve

debug:          ## Debug Jekyll server
debug:
	docker run --rm --volume="$(PWD):/srv/jekyll" -it $(JEKYLL_IMAGE) bash
