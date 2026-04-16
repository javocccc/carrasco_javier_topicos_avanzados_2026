DECLARE
    unique_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(unique_violation, -8001); 
BEGIN
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad)
    VALUES (1, 'Félix Nilo', 'Coquimbo'); 

    DBMS_OUTPUT.PUT_LINE('Tupla insertada correctamente.');

EXCEPTION
    WHEN unique_violation THEN
        DBMS_OUTPUT.PUT_LINE('Error TimesTen capturado: Violación de clave única. El ID ingresado ya existe (TT8001).');
        
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error Oracle capturado: Violación de restricción de unicidad (ORA-00001).');
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/