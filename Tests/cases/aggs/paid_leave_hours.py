from Tests.env import ADMIN


start = '2023-05-01'
end = '2024-03-01'
group_by = '%Y-%Q'
metric = 'Paid Leave Hours'
body = {"Employees": {"include": True, "values": ["1"]}}
role = ADMIN
