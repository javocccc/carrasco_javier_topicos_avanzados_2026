-- ==========================================
-- PRÁCTICA SESIÓN 3: Bloque Anónimo PL/SQL
-- ==========================================

-- Le decimos a la sesión que use nuestro esquema
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

/* DOCUMENTACIÓN DE CRITERIOS DE CLASIFICACIÓN:
Se evaluará el monto total de un pedido de la tabla "Pedidos".
- Criterio ALTO: Si el total del pedido es estrictamente mayor a 700.
- Criterio MEDIO: Si el total del pedido está entre 400 y 700 (inclusive).
- Criterio BAJO: Si el total del pedido es estrictamente menor a 400.
*/

DECLARE
    -- Declaración de variables
    v_pedido_id NUMBER := 101; -- Puedes cambiar este número por 102 o 103 para probar otros resultados
    v_total_pedido NUMBER;
BEGIN
    -- Obtenemos el total del pedido desde la tabla y lo guardamos en la variable
    SELECT Total INTO v_total_pedido
    FROM Pedidos
    WHERE PedidoID = v_pedido_id;

    -- Estructura de control IF para clasificar el monto
    IF v_total_pedido > 700 THEN
        DBMS_OUTPUT.PUT_LINE('El Pedido ' || v_pedido_id || ' tiene un total de $' || v_total_pedido || '. Clasificación: ALTO');
    ELSIF v_total_pedido >= 400 THEN
        DBMS_OUTPUT.PUT_LINE('El Pedido ' || v_pedido_id || ' tiene un total de $' || v_total_pedido || '. Clasificación: MEDIO');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El Pedido ' || v_pedido_id || ' tiene un total de $' || v_total_pedido || '. Clasificación: BAJO');
    END IF;

EXCEPTION
    -- Manejo de errores por si el ID del pedido no existe
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontró ningún registro para el Pedido ' || v_pedido_id);
END;