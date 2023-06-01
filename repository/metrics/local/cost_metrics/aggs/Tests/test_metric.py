from repository.metrics.local.cost_metrics.aggs.metric_aggs import Metric


# yapf: disable
def test_str():
    assert str(Metric('', 'expr1')) == 'expr1'

def test_eq():
    assert Metric('', 'expr1') == Metric('', 'expr1')

def test_add():
    assert Metric('', 'expr1') + Metric('', 'expr2') == Metric('', 'expr1 + expr2')

def test_mul():
    assert Metric('', 'expr1') * 1.0 == Metric('', 'expr1 * 1.0')

def test_div():
    assert Metric('', 'expr1') / Metric('', 'expr2') == Metric('', 'expr1 / expr2')
