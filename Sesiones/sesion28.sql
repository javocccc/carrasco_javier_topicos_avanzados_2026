--1
--Una transacción en una base de datos es una unidad lógica de trabajo que consta de una o más operaciones de base de datos. 
--Estas operaciones deben ejecutarse completamente o no ejecutarse en absoluto para mantener la integridad de los datos. 
--Las propiedades ACID (Atomicidad, Consistencia, Aislamiento y Durabilidad) garantizan la integridad de las transacciones.
--Atomicidad garantiza que todas las operaciones se completen exitosamente o ninguna se ejecuta.
--Consistencia asegura que una transacción lleve la base de datos a un estado válido.
--Aislamiento garantiza que las transacciones concurrentes no interfieran entre si.
--Durabilidad asegura que cuando se confirma una transacción se mantienen sus cambios incluso en caso de fallas en el sistema.

CREATE OR REPLACE PROCEDURE RegistrarPedido (
    p_ClienteID IN NUMBER,
    p_Total IN NUMBER,
    p_FechaPedido IN DATE
) AS
    v_ClienteExiste BOOLEAN;
BEGIN
    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO v_ClienteExiste FROM Clientes WHERE ClienteID = p_ClienteID;
    IF v_ClienteExiste = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El cliente no existe.');
    END IF; 
    -- Crear un savepoint antes de insertar el pedido
    SAVEPOINT antes_insertar_pedido;
    BEGIN
        -- Insertar el pedido
        INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
        VALUES (Pedidos_seq.NEXTVAL, p_ClienteID, p_Total, p_FechaPedido);
        COMMIT; 
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO antes_insertar_pedido;
    END;
END;

--2
/*
Un data warehouse es un sistema centralizado para integrar y almacenar grandes volúmenes de datos, su propósito es
facilitar el análisis empresarial, en cambio, una base de datos operativa tiene como objetivo la ejecución de operaciones
diarias, son mejores para consultas en tiempo real mientras que data warehouse es mejor para datos históricos, en cuanto
a la estructura data warehouse utiliza principalmente esquema en estrella mientras que base de datos operativa utiliza
modelos entidad-relación.
*/
BEGIN 
  CREATE TABLE Fact_Inventario (
     MovimientoID NUMBER PRIMARY KEY,
     ProductoID NUMBER,
     FechaMovimiento DATE,
     TipoMovimiento VARCHAR2(10), Cantidad NUMBER, 
     CONSTRAINT fk_inventario_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID));
END;
/


--3
/*
En oracle, la herencia permite crear nuevos tipos de objetos basados en tipos existentes, heredando todos los atributos y
métodos, la clausula UNDER se utiliza para heredar de tipos ya existentes. 
*/
CREATE OR REPLACE TYPE Cliente AS OBJECT (
    ClienteID NUMBER,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    FechaNacimiento DATE,
    MEMBER FUNCTION esPremium RETURN NUMBER
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY Cliente AS 
    MEMBER FUNCTION esPremium RETURN VARCHAR2 IS
    BEGIN RETURN 0; END;
END;
/   
CREATE OR REPLACE TYPE ClientePremium UNDER Cliente (
    Descuento NUMBER,
    OVERRIDING MEMBER FUNCTION esPremium RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY ClientePremium AS 
    OVERRIDING MEMBER FUNCTION esPremium RETURN NUMBER IS
    BEGIN RETURN Descuento; END;
END;
/
-- Crear un índice en la tabla Clientes para optimizar consultas por ciudad
CREATE INDEX idx_clientes_ciudad ON Clientes(Ciudad);


--4
CREATE INDEX idx_detalles_pedido_producto ON DetallesPedidos (PedidoID, ProductoID);    
    ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_2025_01 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_2025_02 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION p_2025_03 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_2025_04 VALUES LESS THAN (TO_DATE('2025-05-01', 'YYYY-MM-DD')),
    PARTITION p_2025_05 VALUES LESS THAN (TO_DATE('2025-06-01', 'YYYY-MM-DD')),
    PARTITION p_2025_06 VALUES LESS THAN (TO_DATE('2025-07-01', 'YYYY-MM-DD')),
    PARTITION p_2025_07 VALUES LESS THAN (TO_DATE('2025-08-01', 'YYYY-MM-DD')),
    PARTITION p_2025_08 VALUES LESS THAN (TO_DATE('2025-09-01', 'YYYY-MM-DD')),
    PARTITION p_2025_09 VALUES LESS THAN (TO_DATE('2025-10-01', 'YYYY-MM-DD')),
    PARTITION p_2025_10 VALUES LESS THAN (TO_DATE('2025-11-01', 'YYYY-MM-DD')),
    PARTITION p_2025_11 VALUES LESS THAN (TO_DATE('2025-12-01', 'YYYY-MM-DD')),
    PARTITION p_2025_12 VALUES LESS THAN (TO_DATE('2026-01-01', 'YYYY-MM-DD'))
);  
-- Consulta que suma Total por ClienteID en enero de 2025
SELECT ClienteID, SUM(Total) AS TotalEnero2025
FROM Pedidos
WHERE FechaPedido >= TO_DATE('2025-01-01', 'YYYY-MM-DD')
AND FechaPedido < TO_DATE('2025-02-01', 'YYYY-MM-DD')
GROUP BY ClienteID;

















