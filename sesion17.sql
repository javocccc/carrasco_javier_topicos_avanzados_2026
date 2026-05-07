--1
CREATE USER user_analista IDENTIFIED BY analista123;
GRANT CONNECT TO user_analista;
CREATE ROLE rol_analista;
GRANT SELECT ON Clientes TO rol_analista;
GRANT SELECT ON Pedidos TO rol_analista;
GRANT SELECT ON Productos TO rol_analista;
GRANT SELECT ON DetallesPedidos TO rol_analista;
GRANT INSERT ON Pedidos TO rol_analista;
GRANT rol_analista TO user_analista;
--prueba
CONNECT user_analista/analista123;
SELECT * FROM Clientes; 
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (109, 1, 1500, TO_DATE('2025-06-01', 'YYYY-MM-DD'));

--2
CONNECT sys AS sysdba;
AUDIT SELECT ON Clientes BY user_analista;
AUDIT INSERT ON Pedidos BY user_analista;
--acciones
CONNECT user_analista/analista123;
SELECT * FROM Clientes;
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (110, 2, 2000, TO_DATE('2025-06-02', 'YYYY-MM-DD'));
--ver registros
CONNECT sys AS sysdba;
SELECT username, action_name, timestamp
FROM dba_audit_trail
WHERE username = 'USER_ANALISTA';
