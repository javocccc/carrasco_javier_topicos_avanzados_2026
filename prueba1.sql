--PARTE 1
--1) Relación muchos a muchos: Ocurre cuando múltiples registros de una tabla pueden estar relacionados con múltiples registros de otra tabla, para implementarlo se utiliza una tabla intermedia la cual contiene las forean
--key que referencian a las primary key de las tablas, un ejemplo basado en la prueba sería la tabla asignaciones que es la tabla intermedia que conecta agentes e incidentes, contiene las forean key agenteID e incidenteID.


--2) Vistas: Una vista es una tabla virtual que se genera por una consulta SQL, se utiliza para simplificar consultas complejas, mejorar la seguridad y facilitar la visualización de datos, la consulta SQL para crear la 
--vista sería:
CREATE OR REPLACE VIEW horas_incidentes AS
SELECT i.Descripcion, i.Severidad, SUM(a.horas) AS total_horas FROM Incidentes i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
GROUP BY i.Descripcion, i.Severidad;


--3) Excepciones predefinidas: Una excepción predefinida es un error de ORACLE que se activa cuando ocurre un problema durante la ejecución, manejarlas evita que el programa se caiga abruptamente, ejemplo de NOT_DATA_FOUND:
DECLARE a_nombre VARCHAR2(50);
BEGIN
SELECT Nombre INTO a_nombre FROM Agentes WHERE AgenteID = 999;
EXCEPTION 
  WHEN NO_DATA_FOUND THEN 
      DBMS_OUTPUT.PUT_LINE('Error el agente no existe');
END;


--4) Cursores explícitos: Es un puntero de memoria que define el programador, sirve para procesar los resultados de una consulta fila por fila
--Atributos: 1. %NOTFOUND: Devuelve true si el último FETCH no logra recuperar una fila
--           2. %ROWCOUNT: Devuelve la cantidad de filas que el cursor ha extraído
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--PARTE 2
--1) Especialidades de agentes:
DECLARE 
  CURSOR c_especialidades IS 
    SELECT ag.Especialidad, AVG(a.Horas) AS Promedio FROM Agentes ag
    JOIN Asignaciones a ON ag.AgenteID = a.AgenteID
    GROUP BY ag.Especialidad
    HAVING AVG(a.Horas) > 30;
a_espe Agentes.Especialidad%TYPE;
a_prom NUMBER;
BEGIN
DBMS_OUTPUT.PUT_LINE('Especialidades con promedio mayor a 30');
    OPEN c_especialidades;
    LOOP
        FETCH c_especialidades INTO a_espe, a_prom;
        EXIT WHEN c_especialidades%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Especialidad: '  a_espe  '  Promedio: ' ROUND(a_prom, 2));
    END LOOP;
    CLOSE c_especialidades;
END;
/

--3) Objeto:
CREATE OR REPLACE TYPE incidente_obj AS OBJECT (
    incidente_id NUMBER,
    descripcion VARCHAR2(100),
    MEMBER FUNCTION get_reporte RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY incidente_obj AS
    MEMBER FUNCTION get_reporte RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Reporte ID:' SELF.incidente_id 'Detalle:' SELF.descripcion;
    END;
END;
/
CREATE TABLE tabla_incidentes_obj OF incidente_obj;
INSERT INTO tabla_incidentes_obj 
SELECT incidente_obj(IncidenteID, Descripcion) FROM Incidentes;



























