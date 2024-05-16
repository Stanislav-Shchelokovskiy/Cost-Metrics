from Tests.env import ADMIN
from toolbox.sql.generators import NULL_FILTER_VALUE


start = '2023-03-01'
end = '2023-05-01'
body = {"Tents": {"include": True, "values": [NULL_FILTER_VALUE]}}
role = ADMIN
