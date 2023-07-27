from toolbox.sql.connections import SqliteConnection
from toolbox.sql.crud_queries.protocols import CRUDQuery
from toolbox.sql.crud_queries import (
    SqliteUpsertQuery,
    SqliteCreateTableFromTableQuery,
    QueryField,
)
from sql_queries.transform_load.table_defs import get_create_table_statements
from sql_queries.transform_load.index_defs import get_create_index_statements
from repository import RemoteRepository
from sql_queries.index import local_names_index
from sql_queries.meta.cost_metrics import CostmetricsMeta, NameKnotMeta, CostmetricsEmployeesMeta
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
            table_name=local_names_index.CostMetrics.cost_metrics,
            cols=df.columns,
            key_cols=CostmetricsMeta.get_key_fields(),
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
                    source_name=CostmetricsMeta.name,
                    target_name=CostmetricsEmployeesMeta.name,
                    type='TEXT',
                ),
                QueryField(
                    source_name=CostmetricsMeta.position_name,
                    target_name=CostmetricsEmployeesMeta.position,
                    type='TEXT',
                ),
                QueryField(
                    source_name=CostmetricsMeta.tribe_name,
                    target_name=CostmetricsEmployeesMeta.tribe,
                    type='TEXT',
                ),
                QueryField(
                    source_name=CostmetricsMeta.emp_crmid,
                    target_name=CostmetricsEmployeesMeta.crmid,
                    type='TEXT',
                ),
            )
        ),
    )
    __post_process()

def __post_process():
    from config.environ import reset_recalculate_from_beginning
    reset_recalculate_from_beginning()
