import sql_queries.index.path.remote as path_index


class _emps:
    year_month = 'year_month'
    next_year_month = 'next_year_month'
    crmid = 'crmid'
    scid = 'scid'
    name = 'name'
    level_name = 'level_name'
    level_value = 'level_value'
    tax_coefficient = 'tax_coefficient'
    hourly_pay_net = 'hourly_pay_net'
    hourly_pay_gross = 'hourly_pay_gross'
    hourly_pay_gross_withAOE = 'hourly_pay_gross_withAOE'
    retired = 'retired'
    hired_at = 'hired_at'
    retired_at = 'retired_at'
    tribe_id = 'tribe_id'
    tribe_name = 'tribe_name'
    tent_id = 'tent_id'
    tent_name = 'tent_name'
    position_id = 'position_id'
    position_name = 'position_name'
    chapter_id = 'chapter_id'
    has_support_processing_role = 'has_support_processing_role'
    audit_location_id = 'audit_location_id'
    audit_location_name = 'audit_location_name'
    actual_location_id = 'actual_location_id'


params = {
    'employees_json': '',
    'employees_audit_json': '',
    'positions_json': '',
    'locations_json': '',
    'levels_json': '',
}

tbl = '#Employees'

queries = [
    path_index.CostMetrics.months,
    path_index.CostMetrics.parse_employees,
    path_index.CostMetrics.parse_employees_audit,
    path_index.CostMetrics.parse_positions,
    path_index.CostMetrics.parse_locations,
    path_index.CostMetrics.parse_levels,
    path_index.CostMetrics.employees,
]
