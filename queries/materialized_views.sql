create view joined_tables as (
SELECT *
FROM shop_daily_report  shop_daily_report
  INNER JOIN shop shop ON (shop_daily_report.id_shop = shop.id)
  INNER JOIN location location ON (shop.id_location = location.id)
  INNER JOIN time time ON (shop_daily_report.id_time = time.timekey)
);

create view report_join_shop as SELECT *
FROM shop_daily_report
  INNER JOIN shop ON shop_daily_report.id_shop = shop.id

  INNER JOIN public.location location ON (shop.id_location = location.id)
  INNER JOIN public.time time ON (shop_daily_report.id_time = time.timekey);

