from toolbox.sql.connections import SqliteConnection
from toolbox.sql.crud_queries.protocols import CRUDQuery
from toolbox.sql.crud_queries.upsert import SqliteUpsertQuery
from sql_queries.transform_load.table_defs import get_create_table_statements
from sql_queries.transform_load.index_defs import get_create_index_statements
from repository import RemoteRepository
from sql_queries.index import local_names_index
from sql_queries.meta import CostmetricsMeta
from toolbox.sql.db_operations import SaveTableOperation


def _save_tables(*queries: CRUDQuery):
    [
        SaveTableOperation(
            conn=SqliteConnection(),
            query=query,
            tables_defs=get_create_table_statements(),
            create_index_statements=get_create_index_statements(),
        )() for query in queries
    ]


def update_cost_metrics(kwargs: dict):
    df = RemoteRepository.cost_metrics.get_data(**kwargs)
    _save_tables(
        SqliteUpsertQuery(
            table_name=local_names_index.get_cost_metrics_table_name(),
            cols=df.columns,
            key_cols=CostmetricsMeta.get_key_fields(),
            confilcting_cols=CostmetricsMeta.get_conflicting_fields(),
            rows=df.itertuples(index=False),
        )
    )
