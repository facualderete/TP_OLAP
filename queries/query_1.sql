--  Del 30% de los clientes que mas pagan el servicio, qué porcentaje de sus ventas es en credito?
WITH top_30_charges(id, charged) AS (SELECT id, ROUND(charges/100)
  FROM SHOP
  ORDER BY charges desc
  LIMIT 349 * 0.3)
SELECT dreport.id_shop, '$ ' || t30.charged, (round(cast(SUM(credit_sum) as float)/(SUM(credit_sum) + SUM(credit_cuota_sum) + SUM(debit_sum)) * 100) || '%') AS credit_percentage
FROM shop_daily_report dreport
  JOIN top_30_charges t30 ON t30.id = dreport.id_shop
GROUP BY dreport.id_shop, t30.charged
ORDER BY t30.charged DESC
