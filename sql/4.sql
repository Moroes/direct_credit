CREATE TABLE tab (
   id SERIAL,
   ts timestamp NOT NULL,
   data text
) PARTITION BY LIST ((date_trunc('month', ts)));
 
CREATE TABLE tab_def PARTITION OF tab DEFAULT;

CREATE OR REPLACE FUNCTION part_trig() RETURNS trigger
   LANGUAGE plpgsql AS
$$BEGIN
   BEGIN
      EXECUTE
	   format(
            'CREATE TABLE %I (LIKE tab INCLUDING ALL)',
            'tab_' || to_char(NEW.ts, 'YYYY-MM')
         );

      EXECUTE
         format(
            'NOTIFY tab, %L',
            to_char(NEW.ts, 'YYYY-MM')
         );
   EXCEPTION
      WHEN duplicate_table THEN
         NULL;  -- ignore
   END;
 
   EXECUTE
      format(
         'INSERT INTO %I VALUES ($1.*)',
         'tab_' || to_char(NEW.ts, 'YYYY-MM')
      )
      USING NEW;
 
   RETURN NULL;
END;$$;
 
CREATE TRIGGER part_trig
   BEFORE INSERT ON TAB FOR EACH ROW
   WHEN (pg_trigger_depth() < 1)
   EXECUTE FUNCTION part_trig();

INSERT INTO tab (ts, data)
       SELECT clock_timestamp(), 'something'
       FROM generate_series(1, 100000);

INSERT INTO tab (ts, data) values ('2024-03-02'::timestamp, 'tmp');

CREATE OR REPLACE FUNCTION drop_old_partitions() RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    partition_name TEXT;
    drop_query TEXT;
BEGIN
    FOR partition_name IN
        SELECT tablename
		FROM pg_tables
		WHERE schemaname = 'public'
		  AND tablename ~ '^tab_\d{4}-\d{2}$'
		  AND to_date(substring(tablename from 5 for 7), 'YYYY-MM') < (CURRENT_DATE - INTERVAL '2 months')
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', partition_name);
    END LOOP;
END;
$$;