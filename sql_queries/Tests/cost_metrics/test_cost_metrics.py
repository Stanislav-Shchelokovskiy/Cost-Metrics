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
            '/employees/chapters',
            cases.chapters,
        ),
        (
            '/employees/tribes',
            cases.tribes,
        ),
        (
            '/employees/tents',
            cases.tents,
        ),
        (
            '/employees/positions',
            cases.positions,
        ),
        (
            '/employees/locations',
            cases.locations,
        ),
        (
            '/employees/salaries/ph_level_missing',
            cases.ph_level_missing,
        ),
        (
            '/employees/salaries/ph_level_exists',
            cases.ph_level_exists,
        ),
        (
            '/employees/salaries/non_ph_level_missing',
            cases.non_ph_level_missing,
        ),
        (
            '/employees/salaries/only_pos_audit_exists',
            cases.only_pos_audit_exists,
        ),
        (
            '/employees/salaries/only_actual_level_exists',
            cases.only_actual_level_exists,
        ),
        (
            '/employees/salaries/self_employed',
            cases.self_employed,
        ),
    ],
)
@pytest.mark.integration
def test_prerequisites(
    up: str,
    case: cases.TestCase,
):
    with db(
        up=(params.up, f'{params.migrations}{up}.sql'),
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
        up=(params.up, params.cost_metrics),
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
