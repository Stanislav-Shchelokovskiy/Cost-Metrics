import pytest
from collections import ChainMap
from toolbox.sql.aggs import Metric, NONE_METRIC
from wrapt import decorator
from collections.abc import Callable, Iterable
import repository.metrics.local.cost_metrics.aggs.metric_aggs as aggs


basic_metric = Metric('basic metric', '', '', 'expr1')
advanced_metric = Metric('advanced metric', '', '', 'expr2')
admin_metric = Metric('admin metric', '', '', 'expr3')

basic_metrics = {basic_metric.name: basic_metric}
advanced_metrics = {advanced_metric.name: advanced_metric}
admin_metrics = {admin_metric.name: admin_metric}

advanced_role_metrics = ChainMap(basic_metrics, advanced_metrics)
admin_role_metrics = ChainMap(basic_metrics, advanced_metrics, admin_metrics)

ADVANCED = 'advanced'
ADMIN = 'admin'


@decorator
def with_env(
    callable: Callable[..., None],
    instance,
    args: Iterable,
    kwargs: dict,
):
    with pytest.MonkeyPatch.context() as monkeypatch:
        import repository.metrics.local.cost_metrics.aggs.metric_aggs as aggs
        # yapf: disable
        monkeypatch.setenv('ADMIN_ROLE', ADMIN)
        monkeypatch.setenv('ADVANCED_ROLE', ADVANCED)
        monkeypatch.setattr(aggs, 'basic_metrics', basic_metrics)
        monkeypatch.setattr(aggs, 'advanced_role_metrics', advanced_role_metrics)
        monkeypatch.setattr(aggs, 'admin_role_metrics', admin_role_metrics)
        # yapf: enable
        return callable(**kwargs)


@pytest.mark.parametrize(
    'metric_name,role,result',
    [
        (admin_metric.name, '', NONE_METRIC),
        (advanced_metric.name, '', NONE_METRIC),
        (basic_metric.name, '', basic_metric),
        (admin_metric.name, ADVANCED, NONE_METRIC),
        (advanced_metric.name, ADVANCED, advanced_metric),
        (basic_metric.name, ADVANCED, basic_metric),
        (admin_metric.name, ADMIN, admin_metric),
        (advanced_metric.name, ADMIN, advanced_metric),
        (basic_metric.name, ADMIN, basic_metric),
    ],
)
@with_env
def test_get_metric(metric_name, role, result):
    assert aggs.get_metric(metric_name, role) == result


@pytest.mark.parametrize(
    'metric_name,role,result',
    [
        (admin_metric.name, '', False),
        (advanced_metric.name, '', False),
        (basic_metric.name, '', True),
        (admin_metric.name, ADVANCED, False),
        (advanced_metric.name, ADVANCED, True),
        (basic_metric.name, ADVANCED, True),
        (admin_metric.name, ADMIN, True),
        (advanced_metric.name, ADMIN, True),
        (basic_metric.name, ADMIN, True),
    ],
)
@with_env
def test_is_authorized_metric(metric_name, role, result):
    assert aggs.is_authorized_metric(metric_name, role) == result


@pytest.mark.parametrize(
    'role,result',
    [
        ('', basic_metrics),
        (ADVANCED, advanced_role_metrics),
        (ADMIN, admin_role_metrics),
    ],
)
@with_env
def test_get_metrics(role, result):
    assert aggs.get_metrics(role) == result


@pytest.mark.parametrize(
    'role,projector,filter,result',
    [
        (
            ADMIN,
            lambda x: {
                'name': x.name,
                'context': 1
            },
            lambda x: x.name == advanced_metric.name,
            [{
                'name': advanced_metric.name,
                'context': 1
            }],
        ),
        (
            ADVANCED,
            lambda x: {
                'name': x.name,
                'context': 1
            },
            lambda x: x.name == basic_metric.name,
            [{
                'name': basic_metric.name,
                'context': 1
            }],
        ),
    ],
)
@with_env
def test_select_metrics(role, projector, filter, result):
    assert aggs.select_metrics(role, projector, filter) == result
