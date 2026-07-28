#!/bin/bash
docker system prune -a -f && docker compose pull && docker compose down && docker compose run --rm app rake db:migrate && docker compose down && docker compose up -d --remove-orphans
