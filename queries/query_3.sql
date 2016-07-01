-- Ticket promedio por rubro y provincia
select l.province as PROVINCIA, s.category as RUBRO, round(avg(r.sold_avg)/100) as PROMEDIO
from shop_daily_report as r
join shop as s on r.id_shop = s.id
join location as l on s.id_location = l.id
group by l.province, s.category
order by RUBRO, PROMEDIO;
