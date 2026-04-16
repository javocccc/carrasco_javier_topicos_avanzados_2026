DECLARE
    CURSOR c_pedidos(p_cliente_id NUMBER) IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE OF Total; 

    v_pedido_id NUMBER;
    v_total_original NUMBER;
    v_total_nuevo NUMBER;
    
    v_id_cliente_objetivo NUMBER := 1; 
BEGIN
    DBMS_OUTPUT.PUT_LINE('Actualización de Pedidos (Cliente ' || v_id_cliente_objetivo || ')');
    
    OPEN c_pedidos(v_id_cliente_objetivo);
    
    LOOP
        FETCH c_pedidos INTO v_pedido_id, v_total_original;
        EXIT WHEN c_pedidos%NOTFOUND;
        
        v_total_nuevo := v_total_original * 1.10;
        
        UPDATE Pedidos
        SET Total = v_total_nuevo
        WHERE CURRENT OF c_pedidos;
        
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id || ' | Original: $' || v_total_original || ' | Actualizado: $' || v_total_nuevo);
    END LOOP;
    
    CLOSE c_pedidos;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        IF c_pedidos%ISOPEN THEN
            CLOSE c_pedidos;
        END IF;
        ROLLBACK;
END;
/