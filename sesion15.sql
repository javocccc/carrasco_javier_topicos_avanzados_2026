--1
CREATE INDEX idx_detalles_pedido_producto ON 
DetallesPedidos(PedidoID, ProductoID);

EXPLAIN PLAN FOR
SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;

--2
CREATE TABLE Ventas (
VentaID NUMBER PRIMARY KEY,
ClienteID NUMBER,
Total NUMBER,
FechaVenta DATE
)
PARTITION BY HASH (ClienteID)
PARTITIONS 4;

INSERT INTO Ventas (VentaID, ClienteID, Total, FechaVenta)
SELECT PedidoID, ClienteID, Total, FechaPedido
FROM Pedidos;

EXPLAIN PLAN FOR
SELECT ClienteID, SUM(Total) AS TotalVentas
FROM Ventas
GROUP BY ClienteID;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SELECT ClienteID, SUM(Total) AS TotalVentas
FROM Ventas
GROUP BY ClienteID;
