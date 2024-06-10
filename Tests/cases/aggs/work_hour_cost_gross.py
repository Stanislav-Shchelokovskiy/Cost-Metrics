from Tests.env import ADMIN


start = '2023-04-01'
end = '2024-04-01'
group_by = '%Y-%H'
metric = 'Work Hour Cost (gross)'
body = {"Tribes": {"include": True, "values": ['tribe1', 'tribe_2']}}
role = ADMIN
