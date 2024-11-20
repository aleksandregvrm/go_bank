# Load environment variables from .env
ifeq (,$(wildcard ./.env))
  $(error .env file not found)
endif
include .env
export $(shell sed 's/=.*//' .env)

# Creating New Migrations for up and down
createNewMigration:
	migrate create -ext sql -dir db/migration -seq init-schema

# Apply migrations
migrateup:
	migrate -path ./db/migration -database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DB)?sslmode=disable" -verbose up

# Apply Force migrations
migrateupForce:
	migrate -path ./db/migration -database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DB)?sslmode=disable" force 1

# Confirm migrations have been applied
confirmMigrateup:
	docker exec -it banking-application-db-1 psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -c '\dt'

# Remove Last migration applied
migratedown:
	migrate -path ./db/migration -database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DB)?sslmode=disable" -verbose down

# Force database version if dirty
forcedatabaseVersion:
	migrate -path ./db/migration -database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DB)?sslmode=disable" force 1

# Generate Go files with SQL queries...
sqlc: 
	sqlc generate	

# Running Unit test without caching...
test:
	go test -count=1  -v -cover ./...

.PHONY: confirmMigrateup migrateup migratedown createNewMigration migrateupForce forcedatabaseVersion sqlc test
