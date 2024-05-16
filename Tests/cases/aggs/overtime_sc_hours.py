from Tests.env import ADVANCED
from toolbox.sql.generators import NULL_FILTER_VALUE


start = '2023-04-01'
end = '2024-03-01'
group_by = '%Y-%m'
metric = 'Overtime'
body = {"Tents": {"include": True, "values": [NULL_FILTER_VALUE]}}
role = ADVANCED
