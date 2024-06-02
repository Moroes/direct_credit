SELECT *
FROM (
    SELECT
        1 as id,
        '{
            "application_id": 32,
            "client_id": 12,
            "phones": [{"mobile":"9781236232"}, {"work": "9786333231"}, {"home": "4951234311"}],
            "addresses": [
                {"type": "registration", "date":"23-11-2005","address": {"city": "moscow", "street":"Ленина", "house": "1", "flat": 2}},
                {"type": "residential", "date":"30-11-1955","address": {"city": "moscow", "street":"Ленина", "house": "2", "flat": 3}},
                {"type": "work", "date": null, "address":null}
            ],
            "products": {
                "product_cnt": {
                    "pensil": 4,
                    "pen": 5
                },
                "product_cost": {
                    "pensil": 100,
                    "pen": 10
                },
                "total_sum": 450
            }
        }'::jsonb as answer,
        current_timestamp as created_at,
        current_timestamp as updated_at
) subquery
WHERE created_at > current_timestamp - INTERVAL '1 day'; -- updated_at?? interval?? 