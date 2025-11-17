# 1. Docker up, down & Status

docker compose down -v

docker compose up -d

docker ps

# 2. Drop and create tables

docker compose exec -T postgres psql -U common-user-aph -d fma_db < schema.sql

## For windows

type schema.sql | docker compose exec -T postgres psql -U arun-ghontale -d fma_db