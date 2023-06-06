import pytest
from repository.metrics.local.cost_metrics.aggs.metric_aggs import Metric, SUM


# yapf: disable
def test_str():
    assert str(Metric('', 'expr1')) == 'expr1'

def test_eq():
    assert Metric('', 'expr1') == Metric('', 'expr1')

def test_add():
    assert Metric('', 'expr1') + Metric('', 'expr2') == Metric('', 'expr1 + expr2')

def test_mul():
    assert Metric('', 'expr1') * 1.0 == Metric('', '(expr1) * 1.0')

def test_div():
    assert Metric('', 'expr1') / Metric('', 'expr2') == Metric('', '(expr1) * 1.0 / expr2')
# yapf: enable


@pytest.mark.parametrize(
    'func, window, res', [
        (
            SUM('qwe'),
            'wnd',
            'SUM(qwe) OVER (wnd)',
        ),
        (
            SUM('qwe') / SUM('asd'),
            'wnd',
            'IIF(SUM(asd) OVER (wnd) = 0, 0, SUM(qwe) OVER (wnd) * 1.0 / SUM(asd) OVER (wnd))',
        ),
    ]
)
def test_over(func, window, res):
    assert Metric('tst', func).get_over(window) == res
