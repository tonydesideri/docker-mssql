up:
	docker-compose up -d 

.PHONY: up

down: 
	docker-compose down

.PHONY: down

logs:
	docker logs mssql -f

.PHONY: logs

backup:
	./scripts/mssqldatabasebackup.sh

.PHONY: backup

restore:
	./scripts/mssqldatabaserestore.sh

.PHONY: restore