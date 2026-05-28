--PARTE 1
/*
1) Un procedimiento almancenado ejecuta es un bloque PL/SQL con nombre que se almacena en la base de datos y sirve 
para ejecutar acciones (INSERT, UPDATE, etc), una función almacenada es un bloque PL/SQL también pero que devuelve un valor usando RETURN y
se utiliza en expresiones (SELECT, WHERE, etc), como ejemplo de procedimiento almacemado tenemos el ejercicio 1 donde el procedimiento
inserta una nueva fila en asignaciones y actualiza el estado del incidente, como ejemplo para función almacenada tenemos el ejercicio 2
donde solo se calcula y devuelve las horas asignadas a un agente. 
*/

/*
2) Un parámetro IN OUT permite recibir un valor inicial, modificarlo dentro de un procedimiento almacenado y devolver el valor actualizado.
Ejemplo de procedimiento:
*/
CREATE OR REPLACE PROCEDURE ajustar_horas_asignacion (
    p_AsignacionID IN NUMBER,
    p_HorasAjuste IN NUMBER,
    p_HorasActualizadas IN OUT NUMBER
) AS
BEGIN
    UPDATE Asignaciones
    SET Horas = Horas + p_HorasAjuste
    WHERE AsignacionID = p_AsignacionID;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Asignacion no encontrada.');
    END IF;

    SELECT Horas INTO p_HorasActualizadas
    FROM Asignaciones
    WHERE AsignacionID = p_AsignacionID;

    DBMS_OUTPUT.PUT_LINE('Horas ajustadas para asignacion ' || p_AsignacionID || ': ' || p_HorasActualizadas);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/

/*
3) Para usar una función almacenada dentro de una consulta sql se realizan los cálculos y se retorna el valor que resulte del cálculo.
*/
CREATE OR REPLACE FUNCTION horas_incidentes(a_incidenteID NUMBER) RETURN NUMBER IS a_total NUMBER;
BEGIN
SELECT SUM(Horas) INTO a_total FROM Incidentes WHERE IncidenteID = a_incidenteID;

  
/*
4) Triggers: Bloque pl/sql que se ejecuta automaticamente ante eventos como insert, update, delete.
Tipos: Por evento: BEFORE, AFTER, ROW, STATEMENT. Por operación: INSERT, UPDATE, etc.
Ejemplo Trigger:
*/
CREATE OR REPLACE TRIGGER actualizar_estado_incidente AFTER INSERT ON Asignaciones FOR EACH ROW
DECLARE aa_estadoincidente VARCHAR2(20);
BEGIN
    SELECT Estado INTO aa_estadoincidente FROM Incidentes WHERE IncidenteID = :NEW.IncidenteID;
    IF aa_estadoincidente = 'Abierto' THEN      
        UPDATE Incidentes SET Estado = 'En Proceso' WHERE IncidenteID = :NEW.IncidenteID;
    END IF;
EXCEPTION    
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en trigger: ' || SQLERRM);
END;
/ 







--PARTE 2
--1
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas IN NUMBER,
    p_Rol IN VARCHAR2
) AS 
    aa_asignacionid NUMBER;
    aa_estadoincidente VARCHAR2(20);
BEGIN
-- Verificar si existe
    SELECT COUNT(*) INTO aa_asignacionid FROM Agentes WHERE AgenteID = p_AgenteID;
    IF aa_asignacionid = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El agente no existe.');
    END IF;     
-- Verificar si el incidente existe
    SELECT COUNT(*) INTO aa_asignacionid FROM Incidentes WHERE IncidenteID = p_IncidenteID;
    IF aa_asignacionid = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El incidente no existe.');
    END IF;             
-- Verificar si el agente ya está asignado a ese incidente
    SELECT COUNT(*) INTO aa_asignacionid FROM Asignaciones 
    WHERE AgenteID = p_AgenteID AND IncidenteID = p_IncidenteID;
    IF aa_asignacionid > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El agente ya está asignado a este incidente.');
    END IF;
-- Insertar la nueva asignación
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol) 
    VALUES (v_AsignacionID, p_AgenteID  , p_IncidenteID, p_Horas, p_Rol);       
-- Actualizar el estado del incidente 
    SELECT Estado INTO aa_estadoincidente FROM Incidentes WHERE IncidenteID = p_IncidenteID;
    IF aa_estadoincidente = 'Abierto' THEN
        UPDATE Incidentes SET Estado = 'En Proceso' WHERE IncidenteID = p_IncidenteID;
    END IF;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Asignación registrada correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;       
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/   
--Ejecutar el procedimiento
BEGIN   
    registrar_asignacion(102, 204, 30, 'Apoyo'); 
    registrar_asignacion(999, 204, 30, 'Apoyo'); 
END;
/   
-- Verificar cambios
SELECT * FROM Asignaciones;
SELECT * FROM Incidentes WHERE IncidenteID = 204;


--2
CREATE OR REPLACE FUNCTION calcular_horas_agente (p_AgenteID IN NUMBER) RETURN NUMBER AS aa_horas NUMBER;
BEGIN
    SELECT NVL(SUM(Horas), 0) INTO aa_horas FROM Asignaciones WHERE AgenteID = p_AgenteID;
    RETURN aa_horas;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM); 
        RETURN NULL;
END;    
/
CREATE OR REPLACE PROCEDURE mostrar_carga_agentes AS 
BEGIN       
    FOR cc IN (SELECT AgenteID, Nombre, Especialidad FROM Agentes) LOOP
    DBMS_OUTPUT.PUT_LINE('agente: ' || cc.Nombre || 'especialidad: ' || cc.Especialidad || 'total de horas: ' || calcular_horas_agente(cc.AgenteID));
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
-- Ejecutar procedimiento        
BEGIN
    mostrar_carga_agentes;
END;
/   

--3
CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    Fechaa DATE
);      
--Crear trigger
CREATE OR REPLACE TRIGGER auditar_asignaciones AFTER INSERT OR DELETE ON Asignaciones FOR EACH ROW
DECLARE aa_accion VARCHAR2(10);
BEGIN
    IF INSERTING THEN           
        aa_accion := 'INSERT';
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, Fechaa)
        VALUES (AuditoriaAsignaciones_seq.NEXTVAL, :NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, :NEW.Horas, aa_accion, SYSDATE);
    ELSIF DELETING THEN
        aa_accion := 'DELETE';       
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, Fechaa)
        VALUES (AuditoriaAsignaciones_seq.NEXTVAL, :OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID, :OLD.Horas, aa_accion, SYSDATE);
    END IF;
EXCEPTION
    WHEN OTHERS THEN    
        DBMS_OUTPUT.PUT_LINE('Error en trigger de auditoría: ' || SQLERRM);
END;        


