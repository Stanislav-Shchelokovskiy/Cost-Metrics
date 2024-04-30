from sql_queries.meta import CostMetrics


cost_metrics = {
    CostMetrics.emp_crmid.name: ['00000000-0000-0000-0000-000000000001'] * 10,
    CostMetrics.emp_scid.name: ['00000000-0000-0000-0000-000000000001'] * 10,
    CostMetrics.position_id.name:
        [
            '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89',
            '945FDE96-987B-4608-85F4-7393F00D341B',
            '0CF0BDBA-7DE3-4A06-9493-8F90720526B7',
            '7A8E1B05-385E-4C91-B61E-81446B0C404A',
            '5739E91C-83AE-46CB-A9A0-32517CB1BAAA',
            '4D017739-BA85-4C71-AEFD-1B7098BE81A2',
            '7A8E1B05-385E-4C91-B61E-81446B0C404A',
            '7A8E1B05-385E-4C91-B61E-81446B0C404A',
            '7A8E1B05-385E-4C91-B61E-81446B0C404A',
            '7A8E1B05-385E-4C91-B61E-81446B0C404A'
        ],
    CostMetrics.tent_id.name:
        [
            None,
            None,
            None,
            None,
            None,
            None,
            '00000000-0000-0000-0000-000000000003',
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000003',
        ],
    CostMetrics.tribe_id.name:
        [
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000003',
            '00000000-0000-0000-0000-000000000003',
            '00000000-0000-0000-0000-000000000003',
            '00000000-0000-0000-0000-000000000003'
        ],
    CostMetrics.year_month.name:
        [
            '2022-09-01', '2022-10-01', '2022-11-01', '2022-12-01',
            '2023-01-01', '2023-02-01', '2023-05-01', '2023-06-01',
            '2023-07-01', '2023-08-01'
        ],
    CostMetrics.team.name:
        [
            'Support', 'Support', 'Support', 'Support', 'DevTeam', 'DevTeam',
            'Support', 'Support', 'Support', 'Support'
        ],
    CostMetrics.tribe_name.name:
        [
            'tribe1', 'tribe2', 'tribe2', 'tribe2', 'tribe2', 'tribe2',
            'tribe3', 'tribe3', 'tribe3', 'tribe3'
        ],
    CostMetrics.tent_name.name:
        [None, None, None, None, None, None, 'tent3', 'tent1', 'tent1', 'tent3'],
    CostMetrics.name.name: ['emp1'] * 10,
    CostMetrics.position_name.name:
        [
            'support_developer_ph', 'chapter_leader', 'tribe_leader',
            'support_developer', 'developer', 'technical_writer',
            'support_developer', 'support_developer', 'support_developer',
            'support_developer'
        ],
    CostMetrics.level_name.name:
        [
            'trainee_support', 'middle_support', 'middle_dev',
            'middle_support', 'middle_dev', 'senior_support', 'senior_support',
            'senior_support', 'senior_support', 'senior_support'
        ],
    CostMetrics.level_value.name: [3.0, 5, 5, 5, 5, 5.5, 5.5, 5.5, 5.5, 5.5],
    CostMetrics.hourly_pay_net.name:
        [
            6.5480000, 7.7380000, 9.5240000, 7.7380000, 8.9290000, 10.7140000,
            10.7140000, 10.7140000, 10.7140000, 10.7140000
        ],
    CostMetrics.hourly_pay_gross.name:
        [
            6.94, 8.342, 10.267, 8.342, 11.696, 14.036, 14.036, 14.036, 14.036,
            14.036
        ],
    CostMetrics.hourly_pay_gross_withAOE.name:
        [
            18.845, 21.437, 23.362, 21.437, 24.792, 27.131, 27.131, 27.131,
            27.131, 27.131
        ],
    CostMetrics.paid_vacation_hours.name:
        [124.0, 4.0, 0.0, 4.0, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0],
    CostMetrics.free_vacation_hours.name:
        [0.0, 120.0, 4.0, 120.0, 4.0, 0.0, 112.0, 0.0, 0.0, 0.0],
    CostMetrics.paid_hours.name:
        [168.0, 48.0, 164.0, 48.0, 164.0, 32.0, 48.0, 168.0, 168.0, 168.0],
    CostMetrics.sc_hours.name: [22.9, 32.9, 44, 44, 82, 16, 44, 47, 198, 0],
    CostMetrics.sc_paidvacs_hours.name:
        [39.802380952381, 30.9, 44, 45, 82, 16, 45, 47, 165, 0],
    CostMetrics.sc_paidvacs_hours_incl_overtime.name:
        [
            39.802380952381, 35.6416666666667, 44, 47.6666666666667, 82, 16,
            47.6666666666667, 47, 198, 0
        ],
    CostMetrics.overtime_sc_hours.name: [0.0, 0, 0, 0, 0, 0, 0, 0, 33, 0],
    CostMetrics.proactive_paidvacs_hours.name:
        [128.197619047619, 17.1, 120, 3, 82, 16, 3, 121, 3, 168],
    CostMetrics.unique_tickets.name: [3, 4, 5, 5, 4, 4, 3, 3, 3, 0],
    CostMetrics.iterations.name: [5, 5, 5, 5, 5, 5, 5, 5, 23, 0],
    CostMetrics.total_work_hours.name:
        [
            168, 52.7416666666667, 164, 50.6666666666667, 164, 32,
            50.6666666666667, 168, 201, 168
        ],
    CostMetrics.sc_work_cost_gross.name:
        [
            300.518523809524, 285.2964, 451.748, 402.9186, 1025.7392, 224.576,
            708.818, 659.692, 2315.94, 0
        ],
    CostMetrics.sc_work_cost_gross_incl_overtime.name:
        [
            300.518523809524, 324.851383333333, 451.748, 425.163933333333,
            1025.7392, 224.576, 746.247333333333, 659.692, 2779.128, 0
        ],
    CostMetrics.sc_work_cost_gross_withAOE.name:
        [
            774.365869047619, 689.9319, 1027.928, 992.1936, 2099.6112, 434.096,
            1298.093, 1275.157, 4476.615, 0
        ],
    CostMetrics.proactive_work_cost_gross.name:
        [
            889.691476190476, 142.6482, 1232.04, 25.026, 959.072, 224.576,
            42.108, 1698.356, 42.108, 2358.048
        ],
    CostMetrics.proactive_work_cost_gross_withAOE.name:
        [
            2415.88413095238, 366.5727, 2803.44, 64.311, 2032.944, 434.096,
            81.393, 3282.851, 81.393, 4558.008
        ],
    CostMetrics.sc_work_cost_gross_withAOE_incl_overtime.name:
        [
            774.365869047619, 791.579008333333, 1027.928, 1049.35893333333,
            2099.6112, 434.096, 1370.44233333333, 1275.157, 5371.938, 0
        ],
}
