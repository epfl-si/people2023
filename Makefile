-include .env
export
KBPATH = /keybase/team/epfl_people.prod

DATASRC = dinfo@dinfo1.epfl.ch
ACCRED_TABLES = accreds accreds_properties classes deputations guests positions properties properties_units properties_status properties_classes rights rights_classes rights_persons rights_roles rights_statuses rights_units roles_persons statuses
CADI_TABLES = DBClients Manco WSAppsCallers WSAppsHosts WSClients WSServices batch_executions batch_params champs config datafields datatypes dbs delegates eventstypes filters operations pendingnotifications providers resources resources_types subscriptions tbls
CV_TABLES = 
# DINFO_TABLES = SwitchAAIUsers accounts accred adrspost allunits annu delegues emails externalids fonds groups isa_codes Personnel sciper unites_reorg21 unites unites1 isa_etu
DINFO_TABLES = accred

# database manipulation commands 
# make use of lazy evaluation for using variables as function parameters
MYSQL = docker-compose -f $(COMPOSE) exec -T mariadb bash -c 'mysql -u root --password=mariadb'
MYSQLDB = docker-compose -f $(COMPOSE) exec -T mariadb bash -c 'mysql -u root --password=mariadb $(DB)'
MYSQLDUMP=ssh $(DATASRC) "mysqldump -h $(DB_HOST) -u $(DB_USER) -p'$(DB_PASS)' $(DB) $(TABLES) | gzip"
DB_HOST = $(shell ssh $(DATASRC) cat /opt/dinfo/etc/dbs.conf | awk '($$1 == "$(DB)"){printf("%s", $$3);}')
DB_USER = $(shell ssh $(DATASRC) cat /opt/dinfo/etc/dbs.conf | awk '($$1 == "$(DB)"){printf("%s", $$4);}')
DB_PASS = $(shell ssh $(DATASRC) cat /opt/dinfo/etc/dbs.conf | awk '($$1 == "$(DB)"){printf("%s", $$5);}')

COMPOSE ?= docker-compose.yml

kb:
	ln -s $(KBPATH) $@

# ---------------------------------------------------------------- run local app
.PHONY: build up dcup down logs console dbconsole setup

build:
	docker-compose -f $(COMPOSE) build

up: dcup

dcup:
	docker-compose -f $(COMPOSE) up -d 

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

# setup_kc: dcup
# 	sleep 10
# 	docker-compose -f $(COMPOSE) stop keycloak
# 	sleep 2
# 	echo "DROP DATABASE IF EXISTS keycloak;" | $(MYSQL)
# 	sleep 2
# 	echo "CREATE DATABASE keycloak;" | $(MYSQL)
# 	make up

# -------------------------------------------------- restore legacy DB from prod

.PHONY: restore restore_legacy restore_cv restore_cadi restore_dinfo restore_accred

restore: restore_legacy

restore_legacy:  restore_cv restore_cadi restore_dinfo restore_accred

FIXDB = sed 's/0000-00-00 00:00:00/NULL/g' | sed -E "s/(datetime|timestamp) NOT NULL DEFAULT 'NULL'/\1 NOT NULL/g" | sed -E "s/DEFAULT *'NULL'/DEFAULT NULL/g"
restore_accred:
	$(eval DB := accred)
	$(eval TABLES := $(ACCRED_TABLES))
	$(MYSQLDUMP) | gunzip | $(FIXDB) | $(MYSQLDB)

restore_cadi:
	$(eval DB := cadi)
	$(eval TABLES := $(CADI_TABLES))
	$(MYSQLDUMP) | gunzip | $(FIXDB) | $(MYSQLDB)

restore_cv:
	$(eval DB := cv)
	$(eval TABLES := $(CV_TABLES))
	$(MYSQLDUMP) | gunzip | $(FIXDB) | $(MYSQLDB)

restore_dinfo:
	$(eval DB := dinfo)
	$(eval TABLES := $(DINFO_TABLES))
	$(MYSQLDUMP) | gunzip | $(FIXDB) | $(MYSQLDB)
