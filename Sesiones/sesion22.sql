--1
-- Estrategia de Alta Disponibilidad para curso_topicos
-- Nodos:
--   * Nodo principal : Santiago, Chile
--   * Nodo standby  : Valparaíso, Chile
-- Replicación: Asíncrona con Oracle Data Guard
--   * Motivo: Menor latencia en el principal, aceptable para el sistema
-- Uso del standby:
--   * Consultas de solo lectura (reportes de ventas) con Active Data Guard
-- Failover:
--   * Fast-Start Failover para conmutación automática al standby
--   * MTTR objetivo: 5 minutos
-- Consideraciones:
--   * Respaldo completo semanal y archivelogs diarios
--   * Monitoreo con Oracle Enterprise Manager para alertas de fallo

--2
-- Reporte de ventas por cliente ejecutado en el nodo standby (solo lectura)
SELECT c.ClienteID,
       c.Nombre,
       SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD')
                        AND TO_DATE('2025-06-30', 'YYYY-MM-DD')
GROUP BY c.ClienteID, c.Nombre
ORDER BY TotalVentas DESC;

-- Uso de Active Data Guard:
-- El nodo standby opera en modo solo lectura mientras se sincroniza con el principal.
-- Esta consulta se desvía al standby para no afectar el rendimiento del nodo principal.
-- Beneficio: balanceo de carga; escrituras (INSERT/UPDATE) siguen en el principal.
