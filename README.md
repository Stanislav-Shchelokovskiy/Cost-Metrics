### See [Engineering Metrics WIKI](https://github.com/Stanislav-Shchelokovskiy/MetricsUI/blob/release/wiki/WIKI.md) for a full review of the overall platform functionality.


# How to run the app
Add **.env** file containing the following env vars:
- SQL_SERVER=...
- SQL_DATABASE=DXStatisticsV2
- SQL_USER=...
- SQL_PASSWORD=...
- REDIS_PORT=6379
- REDIS_DB=COST_METRICS
- DB_HOME=/root/app/data
- WF_LOGIN_HEADER=AuthLogin
- WF_LOGIN_PASSWORD=AuthPassword
- WF_LOGIN=...
- WF_PASSWORD=...
- WF_ENDPOINT=https://int..com/wf/data/GetDayAppointmentAnalysis
- EMPS_ENDPOINT=https://hr-employee..devx/api/v1/employees?expandDetails=True&expandDataForAnalytics=True&type=ActiveOrRetired&IncludeServiceUsers=True
- EMPS_AUDIT_ENDPOINT=https://hr-employee..devx/api/v1/audit-employees
- EMPS_VACATIONS_ENDPOINT=https://int..com/employees/api/v1/vacations/getVacations
- EMPS_POSITIONS_ENDPOINT=https://hr-employee..devx/api/v1/employeePositions
- EMPS_LOCATIONS_ENDPOINT=https://hr-employee..devx/api/v1/employeeLocations
- EMPS_LEVELS_ENDPOINT=https://hr-employee..devx/api/v1/employeeLevels
- EMPS_APPID=...
- EMPS_USERID=...
- EMPS_APIKEY=...
- AUTH_ENDPOINT=https://graph.microsoft.com/v1.0/me/appRoleAssignments?$select=appRoleId&$filter=resourceId%20eq%204655AF44-BDB5-4060-9BEE-623467B27DD9
- AUTH_ENABLED=1
- CORS_ORIGINS=["https://support.corp.com","http://localhost:3000"]
- ADMIN_ROLE=7B4C4079-B174-425C-8FA8-344B7EF85700
- ADVANCED_ROLE=1D7CFA35-59ED-4F6E-966E-51C0D2670DB3
- PRODUCTION=1 #0 = false, 1 = true
- UPDATE_ON_STARTUP=0 #0 = false, 1 = true
- RECALCULATE_FROM_THE_BEGINNING=0
- RECALCULATE_FOR_LAST_MONTHS=1 # 0 = current, 1 = previous month, 2 = last two months etc. We run calculation every first day of each months for last month. See config:get_schedule and config:offset_in_months for details. So, RECALCULATE_FOR_LAST_MONTHS should be 1 or greater.


Make sure:
<b>support_analytics</b> network is created:<br> **docker network create -d bridge support_analytics**

Then run <b>docker-compose up</b>.

## To run locally
Pull git submodules (**git submodule foreach git pull origin main**).<br>

Then either<br>
- Run <b>docker compose build</b> and <b>docker compose up</b>.<br>
VERSION env var specifies prefix which allows running same container on same machine - just add VERSION to your .env if required and run another version of same containers alongside already running.
<br>

--OR--<br>

 - Create virtual env using [poetry](https://python-poetry.org/docs/#installation). For this run poetry "env use /path/to/python". You can install python from source or download it from a repository. 
 - Install dependencies ("poetry install")
 - Execute ". .dev_env.sh" to export dev env vars
 - start redise_service **docker run -d --name=redis_service -v redis_stack:/data --network=support_analytics --restart always redis/redis-stack:latest** 
 - Run .venv/bin/uvicorn server:app --host 0.0.0.0 --port $SERVER_PORT --reload --log-level=info

## To run on production
Copy docker-compose.yaml and .env to the target machine and run "docker compose up".

# How it works
```mermaid
flowchart
Tasks(Tasks) -->|store data| DataMart{Local sqlite db}
Worker[Worker] -->|run| Tasks -->|extract data| Repository{Remote repository} --> SqlServer{Sql server}
Worker -->|store task states and results|RedisCache[Redis]
Client(Client) -->|request|Server[Server] -->|extract data|LocalRepository{Local repository}  -->|extract data| DataMart
Server -->|push client app states|RedisCache
```

# App components

## config
Stores period and other possible configuration settings.<br>

## sql_queries
Stores
- raw sql queries that are run by query executors via repository (see repository's _init_).
- sql query's meta data which sores column names, index columns and other information about underlying tables.
- index and tables definitions used to create local tables.

## repository
Tasks and other components access data via repositories only which have direct access to data bases. Repositories are split into categories according to their purpose: local accesses only local db, remote accesses only remote db, wf acesses workflow's data.<br>
All repositories contain corresponding query descriptors which are used by query executors to extract data from dbs.<br>
Repositories can be sync or async. Async repositories are used by the server, while sync are used by tasks.<br>
The reason is worker runs their tasks in a process pool in specific sequence. Having async repos not only won't give any benefits, but also may slow calculations.<br>
Having async repositories on the server side will give significant benefit in terms of memory and performance because the server is ASGI application. 

## utils
Contains helpers.

# How to push an update
There are two remote preconfigured branches: release and rc (see .github/workflows).<br>
You create a new local branch, add changes to it, push it to remote and then merge your branch into rc or release (if you are shure you want to update release version directly). Then add VERSION=_rc to the .env file on production machine if you are going to run the release candidate (rc) version or skip it if you want to run release version.

# How to force data recalculation or change update periods?
Data is calculated periodically according to the schedule in **worker.setup_periodic_tasks** on the first day of every month (for the previous month) by default.

- UPDATE_ON_STARTUP env var controls whether or not to start updating DataMart when the service starts (0 = false, 1 = true). Default is 0.
- RECALCULATE_FOR_LAST_MONTHS env var specifies the number of months you need to run update for (0 = current, 1 = previous month, 2 = last two months etc.). So, RECALCULATE_FOR_LAST_MONTHS should be 1 or greater.
- RECALCULATE_FROM_THE_BEGINNING env car controls whether is is necessary to recalculate data from scratch. It is effective only once as it is reset with the help of **toolbox.tasks_config.reset_recalculate_from_beginning** when recalculation is complete (see tasks->tasks->process_staged_data).

At the moment, the service doesn't offer api to change these parameters. So, you need to either:
1. Change them in the running container (support_metrics_worker) with the help of docker exec.
2. Change these params in the .env file and restart the container.

To run (apply) a task manually use [Flower API](https://flower.readthedocs.io/en/latest/api.html#post--api-task-async-apply-(.+)) like following:<br>
POST https://support.corp.com/CostMetricsDash/api/task/async-apply/update_cost_metrics

This is probably the only task you will need to apply if you need to update DataMart out of schedule.

Don't forget to specify auth request header(s) if the service is run [behind reverse proxy](https://flower.readthedocs.io/en/latest/reverse-proxy.html#running-behind-reverse-proxy)
