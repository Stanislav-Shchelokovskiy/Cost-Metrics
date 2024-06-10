from Tests.env import ADVANCED


start = '2023-04-01'
end = '2024-04-01'
group_by = '%Y-%m'
metric = 'SC Work Hours (incl overtime)'
body = {
    "Teams": {
        "include": True,
        "values": ['Support']
    },
    "Tribes": {
        "include": True,
        "values": ['tribe_2']
    },
    "Tents": {
        "include": False,
        "values": ['tent_1']
    },
    "Positions": {
        "include": True,
        "values": ['pos_1']
    }
}
role = ADVANCED
