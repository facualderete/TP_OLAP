-- Top 10 Ranking de ciudades con mas contracargos
select l.city as CIUDAD, sum(r.chargeback_count) as CantidadContracargos, '$ ' || round(sum(r.chargeback_sum)/100) as TotalContracargos -- o r.chargeback_sum
from shop_daily_report as r
join shop as s on r.id_shop = s.id
join location as l on s.id_location = l.id
group by l.city
order by CantidadContracargos desc
limit 10;
