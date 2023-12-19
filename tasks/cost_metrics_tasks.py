from toolbox.sql.connections import SqliteConnection
from toolbox.sql.db_operations import SaveTableOperation
from toolbox.sql.query_executors.sqlite_query_executor import SQLiteNonQueryExecutor
from toolbox.sql.crud_queries.protocols import CRUDQuery
from toolbox.sql.crud_queries import (
    SqliteUpsertQuery,
    SqliteCreateTableFromTableQuery,
    SqliteCreateTableQuery,
    DeleteRowsOlderThanQuery,
)
from toolbox.sql import MetaData
from sql_queries.meta import (
    Employees,
    Teams,
    Tribes,
    Tents,
    Positions,
    CostMetrics,
)
from repository import RemoteRepository


def _save_table(cls: MetaData = MetaData, *queries: CRUDQuery):
    [
        SaveTableOperation(
            conn=SqliteConnection(),
            query=query,
            create_index_statements=cls.get_indices(),
        )()
        for query in queries
    ]


# yapf: disable
def upsert_cost_metrics(
    kwargs: dict,
    employees_json: str,
    employees_audit_json: str
):
    df = RemoteRepository.cost_metrics.get_data(
        **kwargs,
        employees_json=employees_json,
        employees_audit_json=employees_audit_json,
    )
    _save_table(
        CostMetrics,
        SqliteCreateTableQuery(
            target_table_name=CostMetrics.get_name(),
            unique_key_fields=CostMetrics.get_key_fields(lambda x: x.as_query_field()),
            values_fields=CostMetrics.get_conflicting_fields(lambda x: x.as_query_field(), preserve_order=True),
            recreate=False,
        ),
        SqliteUpsertQuery(
            table_name=CostMetrics.get_name(),
            cols=df.columns,
            key_cols=CostMetrics.get_key_fields(),
            confilcting_cols=CostMetrics.get_conflicting_fields(),
            rows=df.itertuples(index=False),
        )
    )


def process_staged_data(years_of_history: str):
    _save_table(
        Teams,
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=CostMetrics.get_name(),
            target_table_name=Teams.get_name(),
            unique_key_fields=(CostMetrics.team.as_query_field(Teams.name),),
        )
    )
    _save_table(
        Tribes,
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=CostMetrics.get_name(),
            target_table_name=Tribes.get_name(),
            unique_key_fields=(
                CostMetrics.tribe_id.as_query_field(Tribes.id),
                CostMetrics.tribe_name.as_query_field(Tribes.name),
            ),
        )
    )
    _save_table(
        Tents,
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=CostMetrics.get_name(),
            target_table_name=Tents.get_name(),
            unique_key_fields=(
                CostMetrics.tent_id.as_query_field(Tents.id),
                CostMetrics.tent_name.as_query_field(Tents.name),
            ),
        )
    )
    _save_table(
        Positions,
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=CostMetrics.get_name(),
            target_table_name=Positions.get_name(),
            unique_key_fields=(
                CostMetrics.position_id.as_query_field(Positions.id),
                CostMetrics.position_name.as_query_field(Positions.name),
            ),
        )
    )
    _save_table(
        Employees,
        SqliteCreateTableFromTableQuery(
            source_table_or_subquery=CostMetrics.get_name(),
            target_table_name=Employees.get_name(),
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
        )
    )
    __execute(
        DeleteRowsOlderThanQuery(
            tbl=CostMetrics.get_name(),
            date_field=CostMetrics.year_month,
            modifier=years_of_history,
        )
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
