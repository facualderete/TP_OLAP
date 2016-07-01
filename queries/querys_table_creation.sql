CREATE TABLE time
(
  timekey int identity(1,1) NOT NULL,
  date date,
  daynameweek character varying(10),
  daynbmonth smallint,
  monthnumber smallint,
  monthname character varying(10),
  quarter smallint,
  semester smallint,
  year smallint,
  CONSTRAINT pk_time_timekey PRIMARY KEY (timekey),
  CONSTRAINT ak_time_date UNIQUE (date)
);

CREATE TABLE location
(
	id		int identity(1,1)		not null,
	zipcode		varchar(50)	not null,
	city		varchar(50)	not null,
	province	varchar(50)	not null,
	country		varchar(50)	not null,
	CONSTRAINT pk_location_id PRIMARY KEY (id)
);

CREATE TABLE shop
(
	id		int identity(1,1)		not null,
	name		varchar(100)	not null,
	source_id	varchar(50)	not null,
	zipcode		varchar(50)	not null,
	cuit		varchar(11)	not null,
	charges		varchar(50),
	date		varchar(10),
	terminals	integer,
	charge_mode	varchar(50),
	category	varchar(50),
	client_source	varchar(50),
	CONSTRAINT pk_shop_id PRIMARY KEY (id)
);

CREATE TABLE shop_daily_report
(
	id			int identity(1,1)   	NOT NULL,
	id_shop			integer,
	id_time			integer,
	source_id		varchar(50)	NOT NULL,
	cuit			varchar(11)	NOT NULL,
	fecha_prov		varchar(10)	NOT NULL,
	sold_sum		integer   	NOT NULL,		
	sold_count		integer   	NOT NULL,
	sold_avg		integer   	NOT NULL,
	debit_sum		integer   	NOT NULL,
	debit_count		integer   	NOT NULL,
	debit_avg		integer   	NOT NULL,
	credit_sum		integer   	NOT NULL,
	credit_count		integer   	NOT NULL,
	credit_avg		integer   	NOT NULL,
	credit_cuota_sum	integer   	NOT NULL,
	credit_cuota_count	integer   	NOT NULL,
	credit_cuota_avg	integer   	NOT NULL,
	chargeback_sum		integer   	NOT NULL,
	chargeback_count	integer   	NOT NULL,
	chargeback_avg		integer   	NOT NULL,
	CONSTRAINT pk_shop_daily_report_id	PRIMARY KEY (id)
);