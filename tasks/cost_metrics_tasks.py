import os
import json
from pandas import DataFrame
import toolbox.sql.sqlite_db as sqlite_db
from toolbox.sql.crud_queries.protocols import CRUDQuery
from toolbox.sql.crud_queries.upsert import SqliteUpsertQuery
from sql_queries.transform_load.table_defs import get_create_table_statements
from sql_queries.transform_load.index_defs import get_create_index_statements
from repository import RemoteRepository
from sql_queries.index import local_names_index
from sql_queries.meta import CostmetricsMeta


# yapf: disable
def _save_tables(tables: dict[str, DataFrame | CRUDQuery]):
    sqlitedb = sqlite_db.get_or_create_db()
    sqlitedb.save_tables(
        tables=tables,
        tables_defs=get_create_table_statements(),
        create_index_statements=get_create_index_statements(),
    )
# yapf: enable


def update_cost_metrics(kwargs: dict):
    df = RemoteRepository.cost_metrics.get_data(**kwargs)
    _save_tables(
        tables={
            local_names_index.get_cost_metrics_table_name():
                SqliteUpsertQuery(
                    table_name=local_names_index.get_cost_metrics_table_name(),
                    cols=df.columns,
                    key_cols=CostmetricsMeta.get_key_fields(),
                    confilcting_cols=CostmetricsMeta.get_conflicting_fields(),
                    rows=df.itertuples(index=False),
                )
        }
    )
