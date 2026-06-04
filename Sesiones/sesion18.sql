--1
CREATE OR REPLACE PACKAGE gestion_clientes AS
    PROCEDURE registrar_cliente(p_ClienteID NUMBER, p_Nombre VARCHAR2, p_Ciudad VARCHAR2, p_FechaNacimiento DATE);
    FUNCTION obtener_edad(p_ClienteID NUMBER) RETURN NUMBER;
END gestion_clientes;
/   
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS
    v_cliente_count NUMBER := 0; -- Variable global para contar clientes registrados

    PROCEDURE registrar_cliente(p_ClienteID NUMBER, p_Nombre VARCHAR2, p_Ciudad VARCHAR2, p_FechaNacimiento DATE) IS
    BEGIN
        IF p_FechaNacimiento >= SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
        END IF;

        INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento) 
        VALUES (p_ClienteID, p_Nombre, p_Ciudad, p_FechaNacimiento);
        
        v_cliente_count := v_cliente_count + 1; -- Incrementar el contador de clientes
    END registrar_cliente;

    FUNCTION obtener_edad(p_ClienteID NUMBER) RETURN NUMBER IS
        v_FechaNacimiento DATE;
        v_Edad NUMBER;
    BEGIN
        SELECT FechaNacimiento INTO v_FechaNacimiento FROM Clientes WHERE ClienteID = p_ClienteID;
        v_Edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_FechaNacimiento) / 12);
        RETURN v_Edad;
    END obtener_edad;
END gestion_clientes;
/
-- Probar el paquete
BEGIN
    gestion_clientes.registrar_cliente(4, 'Carlos Sanchez', 'Concepcion', TO_DATE('1988-07-22', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Cliente registrado. Edad: ' || gestion_clientes.obtener_edad(4));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/   

--2
CREATE OR REPLACE PACKAGE gestion_clientes AS
    PROCEDURE registrar_cliente(p_ClienteID NUMBER, p_Nombre VARCHAR2, p_Ciudad VARCHAR2, p_FechaNacimiento DATE);
    FUNCTION obtener_edad(p_ClienteID NUMBER) RETURN NUMBER;
    EXCEPTION e_edad_invalida; -- Excepción personalizada para edad inválida
END gestion_clientes;
/
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS
    v_cliente_count NUMBER := 0; -- Variable global para contar clientes registrados    

    PROCEDURE registrar_cliente(p_ClienteID NUMBER, p_Nombre VARCHAR2, p_Ciudad VARCHAR2, p_FechaNacimiento DATE) IS
        v_Edad NUMBER;
    BEGIN
        IF p_FechaNacimiento >= SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
        END IF; 
        v_Edad := TRUNC(MONTHS_BETWEEN(SYSDATE, p_FechaNacimiento) / 12);
        IF v_Edad < 18 THEN
            RAISE e_edad_invalida; -- Lanzar la excepción personalizada si el cliente es menor de edad
        END IF;
        INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento) 
        VALUES (p_ClienteID, p_Nombre, p_Ciudad, p_FechaNacimiento);    
        v_cliente_count := v_cliente_count + 1; -- Incrementar el contador de clientes
    END registrar_cliente;  

    FUNCTION obtener_edad(p_ClienteID NUMBER) RETURN NUMBER IS
        v_FechaNacimiento DATE;
        v_Edad NUMBER;  
    BEGIN   
        SELECT FechaNacimiento INTO v_FechaNacimiento FROM Clientes WHERE ClienteID = p_ClienteID;
        v_Edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_FechaNacimiento) / 12);
        RETURN v_Edad;
    END obtener_edad;
END gestion_clientes;
/
-- Probar el paquete con un cliente menor de edad
BEGIN
    gestion_clientes.registrar_cliente(5, 'Sofia Martinez', 'La Serena', TO_DATE('2010-08-15', 'YYYY-MM-DD'));
EXCEPTION
    WHEN gestion_clientes.e_edad_invalida THEN
        DBMS_OUTPUT.PUT_LINE('Error: El cliente debe ser mayor de 18 años para  registrarse.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/   
