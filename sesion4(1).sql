DECLARE
    v_valor NUMBER;
    v_bias NUMBER := 50;           
    valor_muy_bajo EXCEPTION;      
BEGIN
    SELECT Precio INTO v_valor
    FROM Productos
    WHERE ProductoID = 1;

    IF v_valor < v_bias THEN
        RAISE valor_muy_bajo;
    END IF;

    DBMS_OUTPUT.PUT_LINE('El valor es aceptable: ' || v_valor);

EXCEPTION
    WHEN valor_muy_bajo THEN
        DBMS_OUTPUT.PUT_LINE('Error: El valor numérico es menor al bias establecido (' || v_bias || ').');
    
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontró el registro solicitado en la tabla.');
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/