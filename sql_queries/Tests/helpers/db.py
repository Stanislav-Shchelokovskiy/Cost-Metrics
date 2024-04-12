import os
import subprocess
from contextlib import contextmanager


@contextmanager
def db(up: str, down: str):
    try:
        sqlcmd = [
            '/opt/mssql-tools18/bin/sqlcmd',
            '-S',
            os.environ['SQL_SERVER_SQLCMD'],
            '-U',
            os.environ['SQL_USER'],
            '-P',
            os.environ['SQL_PASSWORD'],
            '-C',
            '-i',
        ]
        subprocess.run([*sqlcmd, up, '-I'])
        yield
    finally:
        subprocess.run([*sqlcmd, down])
