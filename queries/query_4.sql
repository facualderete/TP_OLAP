-- Ranking de meses con mas ventas en credito, debito y credito en cuotas
select t.year as ANIO, t.monthname as MES, round(sum(credit_sum)/100) as CREDITO
from shop_daily_report as r
join time as t on r.id_time = t.timekey
group by t.year, t.monthname
order by CREDITO desc
limit 10;

select t.year as ANIO, t.monthname as MES, round(sum(debit_sum)/100) as DEBITO
from shop_daily_report as r
join time as t on r.id_time = t.timekey
group by t.year, t.monthname
order by DEBITO desc
limit 10;

select t.year as ANIO, t.monthname as MES, round(sum(credit_cuota_sum)/100) as CUOTAS
from shop_daily_report as r
join time as t on r.id_time = t.timekey
group by t.year, t.monthname
order by CUOTAS desc
limit 10;
