-- Le decimos a esta pestaña que use el esquema correcto
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

-- 1. Realice 2 sentencias SELECT simples
SELECT Nombre, Precio FROM Productos ORDER BY Precio DESC;
SELECT * FROM Clientes WHERE Ciudad = 'Santiago';

-- 2. Realice 2 sentencias SELECT utilizando funciones agregadas
SELECT COUNT(PedidoID) AS Total_Pedidos FROM Pedidos;
SELECT AVG(Total) AS Monto_Promedio FROM Pedidos;

-- 3. Realice 2 sentencias SELECT utilizando expresiones regulares
SELECT Nombre, Ciudad FROM Clientes WHERE REGEXP_LIKE(Nombre, '^M');
SELECT Nombre, Precio FROM Productos WHERE REGEXP_LIKE(Nombre, 'o');

-- 4. Cree 2 vistas
CREATE VIEW Vista_Clientes_Santiago AS
SELECT ClienteID, Nombre, FechaNacimiento FROM Clientes WHERE Ciudad = 'Santiago';

CREATE VIEW Vista_Resumen_Ventas AS
SELECT p.PedidoID, c.Nombre AS Cliente, p.Total, p.FechaPedido
FROM Pedidos p JOIN Clientes c ON p.ClienteID = c.ClienteID;
