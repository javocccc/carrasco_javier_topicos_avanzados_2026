CREATE OR REPLACE TYPE t_producto AS OBJECT (
    nombre VARCHAR2(50),
    precio NUMBER,
    MEMBER FUNCTION aplicar_aumento(porcentaje NUMBER) RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY t_producto AS
    MEMBER FUNCTION aplicar_aumento(porcentaje NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN SELF.precio * (1 + porcentaje/100);
    END;
END;
/
--EJ1
DECLARE
    CURSOR c_lista_productos IS
        SELECT t_producto(Nombre, Precio) 
        FROM Productos
        ORDER BY Precio DESC;
    v_obj t_producto;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Listado ---');
    OPEN c_lista_productos;
    LOOP
        FETCH c_lista_productos INTO v_obj;
        EXIT WHEN c_lista_productos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Prod: ' || v_obj.nombre || ' | Precio: ' || v_obj.precio);
    END LOOP;
    CLOSE c_lista_productos;
END;
/
--EJ2
DECLARE
    CURSOR c_actualizar(p_id NUMBER) IS
        SELECT ProductoID, Nombre, Precio
        FROM Productos
        WHERE ProductoID = p_id
        FOR UPDATE;
    v_id NUMBER; v_nom VARCHAR2(50); v_pre_orig NUMBER; v_pre_nuevo NUMBER;
    v_obj t_producto;
BEGIN
    OPEN c_actualizar(101);
    FETCH c_actualizar INTO v_id, v_nom, v_pre_orig;
    IF c_actualizar%FOUND THEN
        v_obj := t_producto(v_nom, v_pre_orig);
        v_pre_nuevo := v_obj.aplicar_aumento(10);
        UPDATE Productos SET Precio = v_pre_nuevo WHERE CURRENT OF c_actualizar;
        DBMS_OUTPUT.PUT_LINE('Actualizado: ' || v_pre_nuevo);
    END IF;
    CLOSE c_actualizar;
    COMMIT;
END;
/
