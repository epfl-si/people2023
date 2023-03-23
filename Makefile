-include .env
KBPATH = /keybase/team/epfl_people.prod
COMPOSE ?= docker-compose.yml
SSH_AUTH_SOCK_FILE ?= $(SSH_AUTH_SOCK)
SSH_AUTH_SOCK_DIR = $(dir $(SSH_AUTH_SOCK_FILE))

export

kb:
	ln -s $(KBPATH) $@

# ---------------------------------------------------------------- run local app
.PHONY: build up dcup down logs console dbconsole setup

build:
	docker-compose -f $(COMPOSE) build

kup:
	KILLPID=1 docker-compose -f $(COMPOSE) up -d

up: dcup

dcup:
	docker-compose -f $(COMPOSE) up -d 

kc:
	docker-compose --profile kc -f $(COMPOSE) up -d keycloak

# atela:
# 	docker-compose --profile atela -f $(COMPOSE) up -d atela

down: 
	docker-compose -f $(COMPOSE) down

logs:
	docker-compose -f $(COMPOSE) logs -f

ps:
	docker-compose -f $(COMPOSE) ps

console: dcup
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails console

shell: dcup
	docker-compose -f $(COMPOSE) exec webapp /bin/bash

dbconsole: dcup
	docker-compose -f $(COMPOSE) exec mariadb mysql -u root --password=mariadb 

migrate: dcup
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails db:migrate

# setup_kc: dcup
# 	sleep 10
# 	docker-compose -f $(COMPOSE) stop keycloak
# 	sleep 2
# 	echo "DROP DATABASE IF EXISTS keycloak;" | $(MYSQL)
# 	sleep 2
# 	echo "CREATE DATABASE keycloak;" | $(MYSQL)
# 	make up

# -------------------------------------------------- restore legacy DB from prod
# since we moved this to the external script we keep them just as a reminder

.PHONY: restore restore_legacy restore_cv restore_cadi restore_dinfo restore_accred

restore: restore_legacy

restore_legacy:
	./bin/restoredb.sh all

restore_accred:
	./bin/restoredb.sh accred

restore_bottin:
	./bin/restoredb.sh bottin	

restore_cadi:
	./bin/restoredb.sh cadi

restore_cv:
	./bin/restoredb.sh cv

restore_dinfo:
	./bin/restoredb.sh dinfo