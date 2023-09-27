importenv
export REDIS_PORT=6379
export REDIS_SERVICE=localhost
export CELERY_BROKER_URL=redis://${REDIS_SERVICE}:6379/0
export CELERY_RESULT_BACKEND=redis://${REDIS_SERVICE}:6379/0
export DB_HOME=/home/shchelokovskiy/code/cost_metrics/data
export SQLITE_DATABASE=/home/shchelokovskiy/code/cost_metrics/data/db
export REDIS_DB=COST_METRICS
export RECALCULATE_FROM_THE_BEGINNING=0
export RECALCULATE_FOR_LAST_MONTHS=3
export SERVER_PORT=11002
export VERSION=_rc