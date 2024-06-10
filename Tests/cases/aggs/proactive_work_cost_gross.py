from Tests.env import ADMIN


start = '2023-05-01'
end = '2024-03-01'
group_by = '%Y-%m'
metric = 'Proactive Work Cost (gross)'
body = {"Teams": {"include": False, "values": ['DevTeam']}}
role = ADMIN
