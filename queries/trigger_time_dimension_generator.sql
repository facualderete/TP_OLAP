DROP TRIGGER IF EXISTS write_new_date ON shop_daily_report;
DROP FUNCTION write_new_date();
CREATE OR REPLACE FUNCTION write_new_date() RETURNS trigger AS
$write_new_date$
DECLARE
d timestamp = to_timestamp(NEW.fecha_prov, 'YYYY-MM-DD');
time_id	int;
BEGIN
	select timekey into time_id from time where time.year = EXTRACT(YEAR FROM d) and time.monthnumber = EXTRACT(MONTH FROM d)
		and time.daynbmonth = EXTRACT(DAY FROM d);
	IF time_id is null THEN
		INSERT INTO TIME (DATE,daynameweek,daynbmonth,monthnumber,monthname,quarter,semester,year)
		VALUES
		(
		  d,
		  to_char(d, 'Day'),
		  EXTRACT(DAY FROM d),
		  EXTRACT(MONTH FROM d),
		  to_char(d, 'Month'),
		case when EXTRACT(MONTH FROM d) between 1 and 3 then 1
			when EXTRACT(MONTH FROM d) between 4 and 6 then 2
			when EXTRACT(MONTH FROM d) between 7 and 9 then 3
			when EXTRACT(MONTH FROM d) between 10 and 12 then 4
			else 0
		end,
		  
		case when EXTRACT(MONTH FROM d) between 1 and 6 then 1
			when EXTRACT(MONTH FROM d) between 7 and 12 then 2
			else 0
		end,
		  EXTRACT(YEAR FROM d)
		) returning timekey into time_id;
	END IF;

	raise notice 'Value: %', time_id;
	NEW.id_time = time_id;
	RETURN NEW;
END;
$write_new_date$
LANGUAGE plpgsql;

CREATE TRIGGER write_new_date
    BEFORE INSERT ON shop_daily_report
    FOR EACH ROW
    EXECUTE PROCEDURE write_new_date();