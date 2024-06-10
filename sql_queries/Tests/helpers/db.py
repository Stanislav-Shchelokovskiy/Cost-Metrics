import os
import subprocess
from contextlib import contextmanager
from collections.abc import Iterable


@contextmanager
def db(up: str | Iterable[str], down: str):
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
        if isinstance(up, str):
            up = [up]
        for u in up:
            subprocess.run([*sqlcmd, u, '-I'])
        yield
    finally:
        subprocess.run([*sqlcmd, down])
