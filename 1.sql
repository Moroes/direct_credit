CREATE EXTENSION IF NOT EXISTS tablefunc;

WITH min_max_dates AS (
    SELECT
        STAGE,
        MIN(CREATED) AS DATE_START,
        MAX(CREATED) AS DATE_END
    FROM stages
    GROUP BY
        STAGE
)
	
SELECT
    ROW_NUMBER() OVER (ORDER BY ct.STAGE) AS ID,
    ct.STAGE,
    ct.prescoring,
    ct.verification,
    ct.underwriting,
    ct.scoring,
    ct.documents,
    ct.sale,
    ct.abs,
    md.DATE_START,
    md.DATE_END
FROM
    crosstab(
        $$
        SELECT
            STAGE,
            STAGE_NAME,
            STAGE_VALUE
        FROM
            stages
        ORDER BY
            STAGE, STAGE_NAME
        $$,
        $$ VALUES ('prescoring'), ('verification'), ('underwriting'), ('scoring'), ('documents'), ('sale'), ('abs') $$
    ) AS ct (
        STAGE INT,
        prescoring TEXT,
        verification TEXT,
        underwriting TEXT,
        scoring TEXT,
        documents TEXT,
        sale TEXT,
        abs TEXT
    )
JOIN
    min_max_dates md ON ct.STAGE = md.STAGE;
