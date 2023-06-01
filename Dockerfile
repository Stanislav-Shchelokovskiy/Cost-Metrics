FROM python:3.11-bullseye

ENV PYTHONBUFFERED=1

# install pyodbc dependency
RUN apt-get update && \
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    curl https://packages.microsoft.com/config/debian/11/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \ 
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
    ACCEPT_EULA=Y apt-get install -y unixodbc-dev

# install latest sqlite
WORKDIR /root/sqlite
RUN wget https://www.sqlite.org/src/tarball/sqlite.tar.gz && \
    tar xvfz sqlite.tar.gz && mv sqlite/* . && rm -r sqlite && \
    export CFLAGS="-DSQLITE_ENABLE_FTS3 \
    -DSQLITE_ENABLE_FTS3_PARENTHESIS \
    -DSQLITE_ENABLE_FTS4 \
    -DSQLITE_ENABLE_FTS5 \
    -DSQLITE_ENABLE_JSON1 \
    -DSQLITE_ENABLE_LOAD_EXTENSION \
    -DSQLITE_ENABLE_RTREE \
    -DSQLITE_ENABLE_STAT4 \
    -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT \
    -DSQLITE_SOUNDEX \
    -DSQLITE_TEMP_STORE=3 \
    -DSQLITE_USE_URI \
    -O2 \
    -fPIC" && \
    LIBS="-lm" ./configure --disable-tcl --enable-shared --enable-tempstore=always --prefix="/usr" && \
    make && make sqlite3.c && make install

WORKDIR /root/app

# copy dependencies first to make docker cache it and reuse this cache at the next step
COPY pyproject.toml .

# install app dependencies
RUN curl -sSL https://install.python-poetry.org | python3 - --git https://github.com/python-poetry/poetry.git@master && \
    /root/.local/bin/poetry config virtualenvs.create false && \
    /root/.local/bin/poetry install --only main

# copy app
COPY config ./config
COPY repository ./repository
COPY sql_queries ./sql_queries
COPY tasks ./tasks
COPY toolbox ./toolbox
COPY server.py .
COPY server_models.py .
COPY worker.py .