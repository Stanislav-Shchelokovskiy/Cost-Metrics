# install pyodbc dependency
# apt-get update && \
#     curl -sSL https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
#     curl https://packages.microsoft.com/config/debian/11/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
#     apt-get update && \ 
#     ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 && \
#     ACCEPT_EULA=Y apt-get install -y --no-install-recommends unixodbc-dev

export SQL_SERVER=localhost:1434
export SQL_SERVER_SQLCMD=localhost,1434
export SQL_DATABASE=tempdb
export SQL_USER=sa
export SQL_PASSWORD=eRvLhAL104eRvLhAL104
export PRODUCTION=1

docker run \
    -e "ACCEPT_EULA=Y" \
    -e "MSSQL_SA_PASSWORD=${SQL_PASSWORD}" \
    -p 1434:1433 \
    --name sqlserver \
    --hostname sqlserver \
    -d \
    mcr.microsoft.com/mssql/server:2022-latest

.venv/bin/pytest --disable-warnings -vv

docker rm -f sqlserver
