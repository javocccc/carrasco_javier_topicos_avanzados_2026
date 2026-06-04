--1
-- Estrategia de Respaldo
-- - Respaldo completo: Cada domingo a las 23:00
-- - Respaldo incremental (nivel 1): Diariamente a las 23:00
-- - Retención: Mantener respaldos de las últimas 2 semanas
-- - Ubicación: Disco local (/u01/bkp) y copia en la nube (AWS S3)

-- Script RMAN para respaldo completo
rman target /
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 14 DAYS;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u01/bkp/%U';
RUN {
    BACKUP DATABASE PLUS ARCHIVELOG;
    DELETE OBSOLETE;
}

-- Script RMAN para respaldo incremental
RUN {
    BACKUP INCREMENTAL LEVEL 1 DATABASE;
    BACKUP ARCHIVELOG ALL;
}
LIST BACKUP;

--2
-- Simular fallo
DROP TABLE Productos;
-- Verificar
SELECT COUNT(*) FROM Productos; -- Error: tabla no existe

-- Opción 1: Recuperar con Flashback (si está habilitado)
FLASHBACK TABLE Productos TO BEFORE DROP;

-- Opción 2: Si Flashback no está disponible, usar RMAN
rman target /
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
RUN {
    RESTORE TABLE curso_topicos.Productos;
    RECOVER TABLE curso_topicos.Productos;
}
ALTER DATABASE OPEN;

-- Verificar recuperación
SELECT COUNT(*) FROM Productos; 
