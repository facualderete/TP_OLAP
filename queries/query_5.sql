-- Top 3 meses con mas contracargos
select t.year as ANIO, t.monthname as MES, sum(chargeback_count) as CONTRACARGOS, '$' || round(sum(chargeback_sum)/100) as Total_Contracargos
from shop_daily_report as r
join time as t on r.id_time = t.timekey
group by t.year, t.monthname
order by CONTRACARGOS desc limit 3;
