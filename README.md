Add **.env** file containing the following env vars:
- SQL_SERVER=...
- SQL_DATABASE=...
- SQL_USER=...
- SQL_PASSWORD=...
- SERVER_PORT=11006
- FLOWER_PORT=11007
- REDIS_INSIGHT_PORT=10002
- REDIS_PORT=6379
- REDIS_DB=COST_METRICS
- DB_HOME=/root/app/data
- WF_LOGIN_HEADER=AuthLogin
- WF_LOGIN_PASSWORD=AuthPassword
- WF_LOGIN=...
- WF_PASSWORD=...
- WF_ENDPOINT=https://internal.devexpress.com/wf/data/
- CORS_ORIGINS=["http://ubuntu-support.corp.devexpress.com","http://localhost:3000"]
- QUERY_SERVICE=query_service_server:11005
- ADVANCED_MODE_CODE=Advanced
- ADVANCED_MODE_NAME=Advanced
- PRODUCTION=1 # 0 = false, 1 = true

Then run <b>docker-compose up</b>.