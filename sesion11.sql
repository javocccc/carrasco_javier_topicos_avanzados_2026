--1)
CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) RETURN NUMBER AS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    SELECT FechaNacimiento INTO v_fecha_nacimiento
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    RETURN v_edad;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
END;
/
--2)
CREATE OR REPLACE FUNCTION obtener_precio_promedio 
   RETURN NUMBER AS v_promedio NUMBER;
BEGIN
   SELECT AVG(Precio) INTO v_promedio FROM Productos;
   RETURN v_promedio;
END;
/
--Consulta
SELECT Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();
