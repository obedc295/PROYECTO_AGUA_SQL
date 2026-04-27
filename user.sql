-- 1. Crear el usuario común en la base de datos (CDB)
CREATE USER C##AGUAS IDENTIFIED BY oracle;

-- 2. Asignar permisos básicos de conexión y desarrollo
GRANT CONNECT, RESOURCE TO C##AGUAS;

-- 3. Asignar permiso para crear vistas y otros objetos (útil para el modelo HR)
GRANT CREATE VIEW, CREATE TABLE, CREATE SEQUENCE, CREATE PROCEDURE, CREATE MATERIALIZED VIEW TO C##AGUAS;

-- 4. Asignar cuota ilimitada en el tablespace para que no dé error al insertar datos
ALTER USER C##AGUAS QUOTA UNLIMITED ON USERS;

-- 5. Opcional: Dar permisos de depuración (lo que el profesor intentó hacer en clase)
GRANT DEBUG CONNECT SESSION TO C##AGUAS;
GRANT DEBUG ANY PROCEDURE TO C##AGUAS;

-- 6. Si quieres que tenga todos los privilegios administrativos (como un DBA)
GRANT DBA TO C##AGUAS;