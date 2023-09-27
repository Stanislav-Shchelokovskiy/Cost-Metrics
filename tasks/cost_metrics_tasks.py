from toolbox.sql.connections import SqliteConnection
from toolbox.sql.db_operations import SaveTableOperation
from toolbox.sql.query_executors.sqlite_query_executor import SQLiteNonQueryExecutor
from toolbox.sql.crud_queries.protocols import CRUDQuery
from toolbox.sql.crud_queries import (
    SqliteUpsertQuery,
    SqliteCreateTableFromTableQuery,
    SqliteCreateTableQuery,
)
from toolbox.sql.meta_data import KnotMeta
from sql_queries.transform_load.table_defs import get_create_table_statements
from sql_queries.transform_load.index_defs import get_create_index_statements
from sql_queries.index import local_names_index
from sql_queries.meta import CostMetrics, Employees
from repository import RemoteRepository


def _save_tables(*queries: CRUDQuery):
    [
        SaveTableOperation(
            conn=SqliteConnection(),
            query=query,
            tables_defs=get_create_table_statements(),
            create_index_statements=get_create_index_statements(),
        )() for query in queries
    ]


# yapf: disable
def update_cost_metrics(kwargs: dict):
    df = RemoteRepository.cost_metrics.get_data(**kwargs)
    _save_tables(
        SqliteCreateTableQuery(
            target_table_name=local_names_index.CostMetrics.cost_metrics,
            unique_key_fields=CostMetrics.get_key_fields(lambda x: x.as_query_field()),
            values_fields=CostMetrics.get_conflicting_fields(lambda x: x.as_query_field(), preserve_order=True),
            recreate=False,
        ),
        SqliteUpsertQuery(
            table_name=local_names_index.CostMetrics.cost_metrics,
            cols=df.columns,
            key_cols=CostMetrics.get_key_fields(),
            confilcting_cols=CostMetrics.get_conflicting_fields(),
            rows=df.itertuples(index=False),
        )
    )


def process_staged_data():
    _save_tables(
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.teams,
            unique_key_fields=(CostMetrics.team.as_query_field(KnotMeta.name),),
        ),
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.tribes,
            unique_key_fields=(
                CostMetrics.tribe_id.as_query_field(KnotMeta.id),
                CostMetrics.tribe_name.as_query_field(KnotMeta.name),
            ),
        ),
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.tents,
            unique_key_fields=(
                CostMetrics.tent_id.as_query_field(KnotMeta.id),
                CostMetrics.tent_name.as_query_field(KnotMeta.name),
            ),
        ),
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.positions,
            unique_key_fields=(
                CostMetrics.position_id.as_query_field(KnotMeta.id),
                CostMetrics.position_name.as_query_field(KnotMeta.name),
            ),
        ),
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.employees,
            unique_key_fields=None,
            values_fields=(
                CostMetrics.emp_crmid.as_query_field(Employees.crmid),
                CostMetrics.emp_scid.as_query_field(Employees.scid),
                CostMetrics.name.as_query_field(Employees.name),
                CostMetrics.team.as_query_field(Employees.team),
                CostMetrics.tribe_id.as_query_field(Employees.tribe_id),
                CostMetrics.tent_id.as_query_field(Employees.tent_id),
                CostMetrics.position_id.as_query_field(Employees.position_id),
            ),
        ),
    )
    __post_process()


# yapf: enable
def __post_process():
    from toolbox.utils.env import (
        reset_recalculate_from_beginning,
        reset_recalculate_for_last_n_months,
    )
    reset_recalculate_from_beginning()
    reset_recalculate_for_last_n_months()

    __execute('vacuum;')
    __execute('pragma optimize;')


def __execute(query):
    SQLiteNonQueryExecutor().execute_nonquery(query)
