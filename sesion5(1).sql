DECLARE
    CURSOR c_clientes IS
        SELECT Nombre, Ciudad
        FROM Clientes
        ORDER BY Nombre ASC;
        
    v_nombre VARCHAR2(50);
    v_ciudad VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Lista de Clientes Ordenada');
    
    OPEN c_clientes;
    
    LOOP
        FETCH c_clientes INTO v_nombre, v_ciudad;
        EXIT WHEN c_clientes%NOTFOUND; 
        
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre || ' - Ciudad: ' || v_ciudad);
    END LOOP;
    
    CLOSE c_clientes;
END;
/
