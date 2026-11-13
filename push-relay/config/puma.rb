# One process keeps rate-limit counters shared and the SQLite connection local.
workers 0
threads 4, 4
port Integer(ENV.fetch("PORT", "8080"))
environment "production"
quiet
