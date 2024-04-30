import pytest
import sql_queries.Tests.cost_metrics.params as params
import sql_queries.Tests.cost_metrics.cases as cases
from repository import RemoteRepository
from sql_queries.meta import CostMetrics
from sql_queries.Tests.helpers.db import db
from sql_queries.Tests.helpers.df import assert_equal
from toolbox.sql.repository import SqlServerRepository
from toolbox.sql.repository_queries import RepositoryAlchemyQueries, SqlAlchemyQuery


@pytest.mark.parametrize(
    'up, case',
    [
        (
            'months',
            cases.months,
        ),
        (
            'vacations',
            cases.vacations,
        ),
        (
            '/employees/levels',
            cases.levels,
        ),
        (
            '/employees/tents',
            cases.tents,
        ),
    ],
)
@pytest.mark.integration
def test_prerequisites(
    up: str,
    case: cases.TestCase,
):
    with db(
        up=f'{params.migrations}{up}.sql',
        down=params.down,
    ):
        r = SqlServerRepository(
            queries=RepositoryAlchemyQueries(
                prep_queries=[
                    SqlAlchemyQuery(
                        query_file_path=query_file,
                        format_params=case.params,
                    ) for query_file in case.queries
                ],
                main_query_path=params.select,
                main_query_format_params={
                    'select': ','.join(case.want.keys()),
                    'from': case.tbl,
                }
            )
        )
        assert_equal(r.get_data(), case.want, case.dtfields)


@pytest.mark.integration
def test_cost_metrics():
    with db(
        up=params.cost_metrics,
        down=params.down,
    ):
        got = RemoteRepository.cost_metrics.get_data(
            start='2022-09-01',
            end='2023-08-01',
            employees_json='',
            employees_audit_json='',
            vacations_json='',
            positions_json='',
            locations_json='',
            levels_json='',
        )

        assert_equal(got, cases.cost_metrics, [CostMetrics.year_month.name])