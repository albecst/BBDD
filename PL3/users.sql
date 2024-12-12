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
GRANT ALL PRIVILEGES ON TABLE auditoria TO admin;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA base_discos FROM gestor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA base_discos TO gestor;
GRANT SELECT, INSERT ON TABLE auditoria TO gestor;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA base_discos FROM cliente;
GRANT SELECT, INSERT ON base_discos.Tiene, base_discos.Desea, base_discos.Grupo, base_discos.Disco, base_discos.Cancion, base_discos.Edicion TO cliente;
GRANT SELECT, INSERT ON TABLE auditoria TO cliente;
--se han asignado mas permisos de los que pone en el enunciado porque si no el cliente no puede insertar discos  en "Tiene" que no esten en "Disco"

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA base_discos FROM invitado;
GRANT SELECT ON base_discos.Grupo, base_discos.Disco, base_discos.Cancion TO invitado;

GRANT EXECUTE ON FUNCTION auditoria_funcion() TO admin, gestor, cliente;
GRANT EXECUTE ON FUNCTION comprobar_lista_deseados() TO admin, gestor, cliente;

COMMIT;