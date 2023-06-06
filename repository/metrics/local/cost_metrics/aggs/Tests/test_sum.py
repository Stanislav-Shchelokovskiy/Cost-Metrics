from repository.metrics.local.cost_metrics.aggs.metric_aggs import SUM, DIV


# yapf: disable
def test_str_param():
    assert str(SUM('qwe')) == 'SUM(qwe)'


def test_str_expr():
    assert str(SUM('', 'expr1')) == 'expr1'


def test_eq():
    assert SUM('expr1') == SUM('expr1')
    assert str(SUM('', 'expr1')) == 'expr1'


def test_add():
    assert str(SUM('expr1') + SUM('expr2')) == '(SUM(expr1) + SUM(expr2))'


def test_mul():
    assert str(SUM('expr1') * SUM('expr2')) == 'SUM(expr1) * SUM(expr2)'


def test_SUM_over():
    assert SUM('expr1').over('qwe') == 'SUM(expr1) OVER (qwe)'


def test_div():
    assert str(SUM('expr1') / SUM('expr2')) == 'IIF(SUM(expr2) = 0, 0, SUM(expr1) * 1.0 / SUM(expr2))'


def test_div_expr():
    assert str(SUM('', 'expr1') / SUM('', 'expr2')) == 'IIF(expr2 = 0, 0, expr1 * 1.0 / expr2)'


def test_div_over():
    assert DIV(SUM('expr1'), SUM('expr2')).over('qwe') == 'IIF(SUM(expr2) OVER (qwe) = 0, 0, SUM(expr1) OVER (qwe) * 1.0 / SUM(expr2) OVER (qwe))'
