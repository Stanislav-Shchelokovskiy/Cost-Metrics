from toolbox.sql.connections import SqliteConnection
from toolbox.sql.db_operations import SaveTableOperation
from toolbox.sql.query_executors.sqlite_query_executor import SQLiteNonQueryExecutor
from toolbox.sql.crud_queries.protocols import CRUDQuery
from toolbox.sql.crud_queries import (
    SqliteUpsertQuery,
    SqliteCreateTableFromTableQuery,
    QueryField,
)
from sql_queries.transform_load.table_defs import get_create_table_statements
from sql_queries.transform_load.index_defs import get_create_index_statements
from sql_queries.index import local_names_index
from sql_queries.meta.cost_metrics import CostmetricsMeta, NameKnotMeta, CostmetricsEmployeesMeta
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


def update_cost_metrics(kwargs: dict):
    df = RemoteRepository.cost_metrics.get_data(**kwargs)
    _save_tables(
        SqliteUpsertQuery(
            table_name=local_names_index.CostMetrics.cost_metrics,
            cols=df.columns,
            key_cols=CostmetricsMeta.get_index_fields(),
            confilcting_cols=CostmetricsMeta.get_conflicting_fields(),
            rows=df.itertuples(index=False),
        )
    )


# yapf: disable
def process_staged_data():
    _save_tables(
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.teams,
            unique_key_field=QueryField(
                source_name=CostmetricsMeta.team,
                target_name=NameKnotMeta.name,
                type='TEXT',
            )
        ),
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.tribes,
            unique_key_field=QueryField(
                source_name=CostmetricsMeta.tribe_name,
                target_name=NameKnotMeta.name,
                type='TEXT',
            )
        ),
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.tents,
            unique_key_field=QueryField(
                source_name=CostmetricsMeta.tent_name,
                target_name=NameKnotMeta.name,
                type='TEXT',
            )
        ),
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.positions,
            unique_key_field=QueryField(
                source_name=CostmetricsMeta.position_name,
                target_name=NameKnotMeta.name,
                type='TEXT',
            )
        ),
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=local_names_index.CostMetrics.cost_metrics,
            target_table_name=local_names_index.CostMetrics.employees,
            unique_key_field=None,
            values_fields=(
                QueryField(
                    source_name=CostmetricsMeta.emp_crmid,
                    target_name=CostmetricsEmployeesMeta.crmid,
                    type='TEXT',
                ),
                QueryField(
                    source_name=CostmetricsMeta.name,
                    target_name=CostmetricsEmployeesMeta.name,
                    type='TEXT',
                ),
                QueryField(
                    source_name=CostmetricsMeta.team,
                    target_name=CostmetricsEmployeesMeta.team,
                    type='TEXT',
                ),
                QueryField(
                    source_name=CostmetricsMeta.tribe_name,
                    target_name=CostmetricsEmployeesMeta.tribe,
                    type='TEXT',
                ),
                QueryField(
                    source_name=CostmetricsMeta.tent_name,
                    target_name=CostmetricsEmployeesMeta.tent,
                    type='TEXT',
                ),
                QueryField(
                    source_name=CostmetricsMeta.position_name,
                    target_name=CostmetricsEmployeesMeta.position,
                    type='TEXT',
                ),
            )
        ),
    )
    __post_process()

def __post_process():
    from toolbox.utils.env import reset_recalculate_from_beginning
    reset_recalculate_from_beginning()
    __execute('vacuum;')
    __execute('pragma optimize;')

def __execute(query):
    SQLiteNonQueryExecutor().execute_nonquery(query)
