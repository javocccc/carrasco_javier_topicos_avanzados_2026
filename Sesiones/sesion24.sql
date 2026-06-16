--1
-- Crear roles
BEGIN  
    CREATE ROLE Usuario;
    CREATE ROLE Administrador;
END;
/
-- Asignar permisos a roles
BEGIN
    -- Permisos para Usuario
    GRANT SELECT ON Clientes TO Usuario;
    GRANT SELECT ON Pedidos TO Usuario;
    GRANT SELECT ON Productos TO Usuario;
    GRANT SELECT ON DetallesPedidos TO Usuario;
    -- Permisos para Administrador
    GRANT ALL ON Clientes TO Administrador;
    GRANT ALL ON Pedidos TO Administrador;
    GRANT ALL ON Productos TO Administrador;
    GRANT ALL ON DetallesPedidos TO Administrador;
END;
/
-- Crear usuarios y asignar roles
BEGIN 
    CREATE USER usuario1 IDENTIFIED BY pass123;
    CREATE USER admin1 IDENTIFIED BY pass123;
    GRANT Usuario TO usuario1;
    GRANT Administrador TO admin1;
END;
/

--2
-- Consulta crítica: Obtener el total de ventas por cliente
SELECT c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre;      
-- Ejecutar EXPLAIN PLAN para la consulta crítica
EXPLAIN PLAN FOR
SELECT c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre;
-- Ver el plan de ejecución
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- Mejora: Crear un índice en Pedidos.ClienteID para acelerar la consulta
CREATE INDEX idx_pedidos_clienteid ON Pedidos(ClienteID);

EXPLAIN PLAN FOR
SELECT c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID 
GROUP BY c.Nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);  
