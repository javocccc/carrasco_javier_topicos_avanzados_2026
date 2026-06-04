--1)
CREATE OR REPLACE PROCEDURE aumentar_precio_producto(p_producto_id IN NUMBER, p_porcentaje IN NUMBER) AS
BEGIN
    UPDATE Productos
    SET Precio = Precio * (1 + p_porcentaje / 100)
    WHERE ProductoID = p_producto_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Producto con ID ' || p_producto_id || ' no encontrado.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Precio del producto ' || p_producto_id || ' aumentado.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
--2)
CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(p_cliente_id IN NUMBER, p_cantidad OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO p_cantidad
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
EXCEPTION
    WHEN OTHERS THEN
        p_cantidad := 0;
        DBMS_OUTPUT.PUT_LINE('Error al contar pedidos.');
END;
/
