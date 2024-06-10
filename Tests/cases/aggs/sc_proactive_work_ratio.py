from Tests.env import ADVANCED
from toolbox.sql.generators import NULL_FILTER_VALUE


start = '2023-05-01'
end = '2024-03-01'
group_by = '%Y-%Q'
metric = 'SC to Proactive Work Ratio'
body = {
    "Tents": {
        "include": False,
        "values": [NULL_FILTER_VALUE]
    },
}
role = ADVANCED
