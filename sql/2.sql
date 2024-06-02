WITH date_series AS (
  SELECT generate_series(
    '2024-01-01'::date, 
    '2024-12-31', 
    '7 day'::interval
  )::date as series_date
)
select
	to_char(series_date, 'W')::int AS "WEEK_IN_MONTH",
	series_date::date as "MON_DATE_START",
	(series_date + interval '6 day')::date  as "SUN_DATE_END",
	extract('year' from series_date) as "YEAR"
FROM date_series;