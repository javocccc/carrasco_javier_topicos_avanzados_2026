--1
-- Función: precio promedio por pedido de un producto
CREATE OR REPLACE FUNCTION calcular_promedio_pedido(p_prod_id IN NUMBER) RETURN NUMBER AS
    v_avg NUMBER;
BEGIN
    SELECT AVG(pr.Precio * dp.Cantidad) INTO v_avg
    FROM DetallesPedidos dp JOIN Productos pr ON dp.ProductoID = pr.ProductoID
    WHERE dp.ProductoID = p_prod_id;
    RETURN NVL(v_avg, 0);
END;
/

-- Procedimiento: aplica aumento solo a productos con promedio > 500
CREATE OR REPLACE PROCEDURE actualizar_precios_por_categoria(p_porcentaje IN NUMBER) AS
    CURSOR cur_productos IS
        SELECT ProductoID, Precio
        FROM Productos;
BEGIN
    FOR reg IN cur_productos LOOP
        IF calcular_promedio_pedido(reg.ProductoID) > 500 THEN
            UPDATE Productos
            SET Precio = reg.Precio * (1 + p_porcentaje / 100)
            WHERE ProductoID = reg.ProductoID;
            DBMS_OUTPUT.PUT_LINE('Producto ' || reg.ProductoID || ' actualizado.');
        END IF;
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Prueba
EXEC actualizar_precios_por_categoria(10);

--2
-- Tabla de auditoría
CREATE TABLE AuditoriaPedidos (
    AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PedidoID    NUMBER,
    ClienteID   NUMBER,
    Total       NUMBER,
    FechaElim   DATE
);

-- Trigger: registra cada DELETE en Pedidos
CREATE OR REPLACE TRIGGER trg_auditoria_pedido
AFTER DELETE ON Pedidos
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaPedidos (PedidoID, ClienteID, Total, FechaElim)
    VALUES (:OLD.PedidoID, :OLD.ClienteID, :OLD.Total, SYSDATE);
END;
/

-- Prueba
DELETE FROM Pedidos WHERE PedidoID = 102;
SELECT * FROM AuditoriaPedidos;

