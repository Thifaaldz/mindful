.PHONY: up down restart ps logs

up:
	@docker compose up -d --build --quiet-build

down:
	@docker compose down

restart:
	@docker compose down
	@docker compose up -d --build --quiet-build

ps:
	@docker compose ps

logs:
	@docker compose logs -f
