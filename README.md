# How to start the app

Add **.env** file containing the following env vars:
- SQL_SERVER=..
- SQL_DATABASE=..
- SQL_USER=..
- SQL_PASSWORD=..
- SERVER_PORT=11006
- FLOWER_PORT=11007
- REDIS_SERVICE=support_metrics_redis
- REDIS_PORT=6380
- REDIS_DATABASE_PORT=10002
- DB_HOME=/root/app/data
- CORS_ORIGINS=["http://ubuntu-support.corp.devexpress.com","http://localhost:3000"]
- QUERY_SERVICE=query_service_server:11005
- PRODUCTION=1

Make sure:
<b>support_analytics</b> network is created<br>
    docker network create -d bridge support_analytics

Then run <b>docker-compose up</b>.