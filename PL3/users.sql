BEGIN;

--CREATE USER Prueba WITH SUPERUSER PASSWORD 'Prueba';

-- Crear usuarios
/*
CREATE USER admin WITH PASSWORD 'admin';
CREATE USER gestor WITH PASSWORD 'gestor';
CREATE USER cliente WITH PASSWORD 'cliente';
CREATE USER invitado WITH PASSWORD 'invitado';*/

-- Asignar permisos
GRANT USAGE ON SCHEMA base_discos TO admin, gestor, cliente, invitado;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA base_discos TO admin;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA base_discos FROM gestor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA base_discos TO gestor;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA base_discos FROM cliente;
GRANT SELECT, INSERT ON base_discos.Tiene, base_discos.Desea TO cliente;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA base_discos FROM invitado;
GRANT SELECT ON base_discos.Grupo, base_discos.Disco, base_discos.Cancion TO invitado;

COMMIT;