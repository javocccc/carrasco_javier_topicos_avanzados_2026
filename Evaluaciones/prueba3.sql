/*
1.- Una transacción es una unidad lógica de procesamiento que consiste en una o más operaciones en la base de datos, por ejemplo
INSERT, UPDATE, DELETE, todas las que se realizan con exito se guardan sus cambios (commit) o si se deshacen los cambios (rollback).
Propiedades ACID:
Atomicidad: Si una parte de la transacción falla, toda la transacción falla y el estado de la base de datos no cambia.
Consistencia: La transacción debe llevar la base de datos de un estado válido a otro estado válido respetando reglas y restricciones.
Aislamiento: Las transacciones ejecutadas concurrentemente no deben interferir entre sí.
Durabilidad: Cuando se completa con éxito una transacción sus efectos son permanentes.
Ejemplo savepoints:
*/
DECLARE
    v_incidente_id NUMBER := 201;
    v_agente_id NUMBER := 101;
BEGIN
--Inicio de la transacción principal
    SAVEPOINT inicio_transaccion;
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (seq_asignaciones.NEXTVAL, v_agente_id, v_incidente_id, 10, 'Apoyo');
--Guardamos el estado después de una asignación exitosa
    SAVEPOINT asignacion_completada;

    BEGIN
        UPDATE Incidentes
        SET Estado = 'En Progreso'
        WHERE IncidenteID = v_incidente_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO asignacion_completada;
            DBMS_OUTPUT.PUT_LINE('No se pudo actualizar el estado, pero el agente fue asignado.');
    END;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transacción finalizada.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO inicio_transaccion;
        DBMS_OUTPUT.PUT_LINE('Error crítico: Se eliminó la transacción.');
END;
/
/* Qué ocurre si falla solo la actualización del estado?
 El error lo atrapa la excepción interna, se realiza un rollback unicamente a los cambios ocurridos desde el savepoint
 asignacion_completada pero el insert en la tabla asignaciones se mantiene porque ocurrió antes del savepoint.
*/
  
/*
2.- Un data warehouse es un repositorio centralizado de datos estructurados, diseñado para realizar consultas analíticas, generar
reportes y apoyar la toma de decisiones, algunas diferencias con una base de datos transaccional es que el propósito de las 
transaccionales es soportar las operaciones del dia a dia de la empresa y se centra en operaciones más rapidas de lectura/escritura
y actualizaciones constantes mientras que en data warehouse se realizan consultas complejas de solo lectura y escaneo de grandes volumenes
de datos, base de datos transaccional almacena el estado actual de los datos y data warehouse almacena datos históricos.
Para describir el diseño del modelo dimensional iniciaremos con una tabla de hechos que contiene métricas y llaves foráneas que apuntan 
a las dimensiones
Nombre: Hechos_Asignaciones
Métricas: Total_Horas
Llaves: ID_Dim_Agente, ID_Dim_Incidente, ID_Dim_Tiempo
Tablas de dimesiones:
1)Dim_Agente: ID_Dim_Agente, AgenteID, Nombre_Agente, Especialidad
2)Dim_Incidente: ID_Dim_Incidente, IncidenteID, Severidad, Descipción
3)Dim_Tiempo: ID_Dim_Tiempo, Fecha, Año, Mes
Ventajas de este modelo: Rendimiento optimizado porque al estar desnormalizado la base de datos tiene que realizar muchos menos
JOIN complejos, también simplicidad para consultas porque todo es un cruce directo con la tabla central
*/

/*
3.- En Oracle, la herencia se implementa utilizando tipos de objetos, para que un tipo de objeto pueda ser heredado debe ser declarado
con la cláusula NOT FINAL ya que por defecto son FINAL (no heredables), para crear un subtipo que herede de un padre se utiliza la
cláusula UNDER y para sobreescribir los metodos del padre se utiliza OVERRIDING
Ejemplo:
*/
CREATE OR REPLACE TYPE Agente_obj AS OBJECT (
    AgenteID NUMBER,
    Nombre VARCHAR2(50),
    Tarifa_Base NUMBER,
    
    MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT FINAL; 
/

CREATE OR REPLACE TYPE BODY Agente_obj AS
    MEMBER FUNCTION calcular_costo RETURN NUMBER IS
    BEGIN
        RETURN self.Tarifa_Base;
    END;
END;
/
CREATE OR REPLACE TYPE AgenteEspecialista_obj UNDER Agente_obj (
-- Nuevo atributo específico para especialistas
    Bono_Especialidad NUMBER,
-- Indicamos que vamos a sobreescribir el método del padre
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY AgenteEspecialista_obj AS
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER IS
    BEGIN
        -- El especialista suma un bono a su tarifa base
        RETURN self.Tarifa_Base + self.Bono_Especialidad;
    END;
END;
/
CREATE OR REPLACE TYPE AgentePentester_obj UNDER AgenteEspecialista_obj (
    -- Nuevo atributo específico para pentesters
    Herramienta_Principal VARCHAR2(50),
    
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY AgentePentester_obj AS
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER IS
    BEGIN
        RETURN (self.Tarifa_Base + self.Bono_Especialidad) * 1.5;
    END;
END;
/
/*
Implicancias de declarar NOT INSTANTIABLE
No se pueden crear objetos directos como al poner de padre a Agente_obj no se puede hacer un new Agente_obj
Si se declara un metodo como NOT INSTANTIABLE dentro de un tipo no se le crea cuerpo (body) esto obliga a que cualquier
subtipo que si sea instanciable a implementar ese método obligatoriamente.
*/
  
/*
4.- Ventajas y desventajas de indices y particiones
Indices
Ventajas: Aceleran las lecturas ya que mejoran el rendimiento de las consultas y integridad ya que los indices unicos garantizan
que no existan valores duplicados.
Desventajas: Cada vez que se hace un INSERT, UPDATE, DELETE el motor también debe actualizar el indice por lo que ralentiza esas
operaciones y los indices ocupan espacio adicional en el disco duro.
Particiones
Ventajas: Rendimiento en tablas gigantes ya que permite dividir una tabla enorme en pedazos más pequeños, mantenibilidad porque facilita
tareas administrativas como respaldar datos antiguos.
Desventajas: Añaden complejidad al diseño y desarrollo de la base de datos y ineficiencia si se diseña mal 

Para optimizar las consultas en la tabla incidentes se podría utilizar partición por rango basandose en la columna FechaDeteccion ya que 
lo ideal sería hacer particiones mensuales o trimestrales, también con un indice compuesto en las columnas severidad y fechadeteccion.

El partition pruning ocurre cuando la base de datos analiza la cláusula WHERE y se da cuenta que puede ignorar por completo las 
particiones que no tienen datos buscados, impacta positivamente en el plan de ejecucion ya que puede facilitar la busqueda de información.
*/

--PARTE 2

--1
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID    IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas       IN NUMBER,
    p_Rol         IN VARCHAR2
) IS
    v_AsignacionID  NUMBER;
    v_total_horas   NUMBER;
    v_total_agentes NUMBER;
BEGIN
    SAVEPOINT sp_val_agentes;
    BEGIN
        -- Validar que el incidente no tenga ya 3 o más agentes asignados
        SELECT COUNT(DISTINCT AgenteID)
        INTO v_total_agentes
        FROM Asignaciones
        WHERE IncidenteID = p_IncidenteID;
        
        IF v_total_agentes >= 3 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Validación fallida: El incidente ' || p_IncidenteID || ' ya cuenta con 3 o más agentes asignados.');
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO sp_val_agentes;
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
            RETURN; 
    END;

    SAVEPOINT sp_val_horas;
    BEGIN
        SELECT NVL(SUM(a.Horas), 0)
        INTO v_total_horas
        FROM Asignaciones a
        JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
        WHERE a.AgenteID = p_AgenteID 
          AND i.Estado = 'Abierto';
        
        -- Validar que sumando las nuevas horas no supere 100
        IF (v_total_horas + p_Horas) > 100 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Validación fallida: El agente ' || p_AgenteID || ' supera el límite de 100 horas totales permitidas en incidentes abiertos.');
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO sp_val_horas;
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
            RETURN; 
    END;

    SAVEPOINT sp_insercion;
    BEGIN
        SELECT NVL(MAX(AsignacionID), 0) + 1 
        INTO v_AsignacionID 
        FROM Asignaciones;
        
        INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
        VALUES (v_AsignacionID, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Asignación registrada correctamente con el ID ' || v_AsignacionID || '.');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO sp_insercion;
            DBMS_OUTPUT.PUT_LINE('Error al insertar la asignación: ' || SQLERRM);
    END;
END registrar_asignacion;
/

  
--2
--Diseño data warehouse
  
CREATE TABLE Dim_Agente (
    ID_Dim_Agente         NUMBER PRIMARY KEY, 
    AgenteID_Transaccional NUMBER,            
    Nombre                VARCHAR2(50),
    Especialidad          VARCHAR2(50)
);


CREATE TABLE Dim_Incidente (
    ID_Dim_Incidente         NUMBER PRIMARY KEY, 
    IncidenteID_Transaccional NUMBER,            
    Descripcion              VARCHAR2(100),
    Severidad                VARCHAR2(20),
    Estado                   VARCHAR2(20)
);


CREATE TABLE Fact_Asignaciones (
    ID_Dim_Agente    NUMBER,
    ID_Dim_Incidente NUMBER,
    Total_Horas      NUMBER, 
    CONSTRAINT fk_fact_agente    FOREIGN KEY (ID_Dim_Agente)    REFERENCES Dim_Agente(ID_Dim_Agente),
    CONSTRAINT fk_fact_incidente FOREIGN KEY (ID_Dim_Incidente) REFERENCES Dim_Incidente(ID_Dim_Incidente)
);
--Consulta analítica
SELECT 
    ag.Nombre AS Nombre_Agente,
    NVL(SUM(a.Horas), 0) AS Total_Horas_Trabajadas,
    COUNT(DISTINCT a.IncidenteID) AS Numero_Incidentes_Atendidos
FROM Agentes ag
LEFT JOIN 
    Asignaciones a ON ag.AgenteID = a.AgenteID
GROUP BY ag.Nombre, ag.AgenteID
ORDER BY Total_Horas_Trabajadas DESC;


--3
CREATE INDEX idx_inc_sev_fecha ON Incidentes (Severidad, FechaDeteccion);
CREATE TABLE Incidentes_Particionada (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
)
PARTITION BY RANGE (FechaDeteccion) (
    --Trimestre 1
    PARTITION p_2026_q1 VALUES LESS THAN (TO_DATE('2026-04-01', 'YYYY-MM-DD')),
    --Trimestre 2
    PARTITION p_2026_q2 VALUES LESS THAN (TO_DATE('2026-07-01', 'YYYY-MM-DD')),
    --Trimestre 3
    PARTITION p_2026_q3 VALUES LESS THAN (TO_DATE('2026-10-01', 'YYYY-MM-DD')),
    --Trimestre 4
    PARTITION p_2026_q4 VALUES LESS THAN (TO_DATE('2027-01-01', 'YYYY-MM-DD')),
    PARTITION p_futuro  VALUES LESS THAN (MAXVALUE)
);
--Consulta analítica
SELECT 
    i.IncidenteID,
    i.Descripcion,
    SUM(a.Horas) AS Total_Horas
FROM Incidentes_Particionada i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical'
    -- Filtro para el primer trimestre 
    AND i.FechaDeteccion >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
    AND i.FechaDeteccion < TO_DATE('2026-04-01', 'YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion;

--Plan de ejecucion con EXPLAIN PLAN
EXPLAIN PLAN FOR
    SELECT i.IncidenteID, i.Descripcion, SUM(a.Horas) AS Total_Horas FROM Incidentes_Particionada i
    JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
    WHERE i.Severidad = 'Critical' AND i.FechaDeteccion >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
    AND i.FechaDeteccion < TO_DATE('2026-04-01', 'YYYY-MM-DD')
    GROUP BY i.IncidenteID, i.Descripcion;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--La principal ventaja aportada es el partition pruning ya que se especifica en el where que solo se quiere el primer trimestre de 2026

