importenv
export REDIS_SERVICE=localhost
export CELERY_BROKER_URL=redis://${REDIS_SERVICE}:6379/1
export CELERY_RESULT_BACKEND=redis://${REDIS_SERVICE}:6379/0
export DB_HOME=/home/shchelokovskiy/code/support_metrics/data
export SQLITE_DATABASE=/home/shchelokovskiy/code/support_metrics/data/db
export REDIS_DB=SUPPORT_METRICS
export QUERY_SERVICE=localhost:11005