\pset pager off

SET client_encoding = 'UTF8';

BEGIN;
\echo 'creando el esquema para la BBDD de discos'
CREATE TABLE IF NO EXISTS Disco(
    Año_Publicacion TEXT NOT NULL,
    Título TEXT NOT NULL,
    Url_Portada TEXT NOT NULL,
    Nombre_Grupo TEXT NOT NULL,
    CONSTRAINT Disco_PK PRIMARY KEY (Año_Publicacion, Título)
    CONSTRAINT Grupo_FK FOREIGN KEY (Nombre_Grupo) REFERENCES Grupo(Nombre) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
)

CREATE TABLE IF NO EXISTS Grupo(
    Nombre TEXT NOT NULL,
    URL_Grupo TEXT NOT NULL,
    CONSTRAINT Nombre_PK PRIMARY KEY (Nombre)
)

CREATE TABLE IF NO EXISTS Usuario(
    Nombre_Usuario TEXT NOT NULL,
    Nombre TEXT NOT NULL,
    Email TEXT NOT NULL,
    Contraseña TEXT NOT NULL,
    CONSTRAINT Usuario_PK PRIMARY KEY (Nombre_Usuario)
)

CREATE TABLE IF NO EXISTS Canción(
    Título TEXT NOT NULL,
    Duración TIME NOT NULL,
    Título_Disco TEXT NOT NULL,
    Año_Publicación_Disco TEXT NOT NULL,
    CONSTRAINT Canción_PK PRIMARY KEY (Título, Año_Publicación_Disco, Título_Disco)
    CONSTRAINT Disco_FK FOREIGN KEY (Año_Publicación_Disco, Título_Disco) REFERENCES Disco(Año_Publicacion), Disco(Título_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
)

CREATE TABLE IF NO EXISTS Edición(
    Formato TEXT NOT NULL,
    Año_Edición TEXT NOT NULL,
    País TEXT NOT NULL,
    Año_Publicación_Disco TEXT NOT NULL,
    Título_Disco TEXT NOT NULL,
    CONSTRAINT Edición_PK PRIMARY KEY (Formato, Año_Edición, País, Año_Publicación_Disco, Título_Disco)
    CONSTRAINT Disco_FK FOREIGN KEY (Año_Publicación_Disco, Título_Disco) REFERENCES Disco(Año_Publicacion), Disco(Título_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
)

CREATE TABLE IF NO EXISTS Desea(
    Año_Publicación_Disco TEXT NOT NULL,
    Título_Disco TEXT NOT NULL,
    Nombre_Usuario TEXT NOT NULL,
    CONSTRAINT Desea_PK PRIMARY KEY (Año_Publicación_Disco, Título_Disco, Nombre_Usuario)
    CONSTRAINT DiscoUsuario_FK FOREIGN KEY (Año_Publicación_Disco, Título_Disco, Nombre_Usuario) REFERENCES  Disco(Año_Publicacion), Disco(Título_Disco), Usuario(Nombre_Usuario) MATCH FULL
)

CREATE TABLE IF NO EXISTS Tiene(
    Formato_Edición TEXT NOT NULL,
    Año_Edición TEXT NOT NULL,
    País_Edición TEXT NOT NULL,
    Año_Publicación_Disco TEXT NOT NULL,
    Título_Disco TEXT NOT NULL,
    Nombre_Usuario TEXT NOT NULL,
    Estado TEXT NOT NULL,
    CONSTRAINT Tiene_PK PRIMARY KEY (Formato_Edición, Año_Edición, Nombre_Usuario, País_Edición, Año_Publicación_Disco, Título_Disco)
    CONSTRAINT EdiciónUsuario_FK FOREIGN KEY (Formato_Edición, Año_Edición, Nombre_Usuario, País_Edición, Año_Publicación_Disco, Título_Disco) REFERENCES Edición(Formato), Edición(Año_Edición), Usuario(Nombre_Usuario), Edición(País), Disco(Año_Publicacion), Disco(Título) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
)

CREATE TABLE IF NO EXISTS Géneros(
    Año_Publicación_Disco TEXT NOT NULL,
    Género TEXT NOT NULL,
    Título_Disco TEXT NOT NULL,
    CONSTRAINT Géneros_PK PRIMARY KEY (Año_Publicación_Disco, Título_Disco, Género)
    CONSTRAINT Disco_FK FOREIGN KEY (Año_Publicación_Disco, Título_Disco) REFERENCES Disco(Año_Publicacion), Disco(Título_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
)

\echo 'creando un esquema temporal'
CREATE TABLE IF NO EXISTS DiscoTemp(
    id_disco TEXT,
    Título TEXT ,
    Año_Publicacion TEXT ,
    id_grupo TEXT,
    Nombre_Grupo TEXT ,
    URL_Grupo TEXT,
    Géneros TEXT ,
    Url_Portada TEXT ,
)


CREATE TABLE IF NO EXISTS UsuarioTemp(
    Nombre_Completo TEXT ,
    Nombre_Usuario TEXT ,
    Email TEXT ,
    Contraseña TEXT ,
)

CREATE TABLE IF NO EXISTS CanciónTemp(
    id_disco TEXT;
    Título TEXT ,
    Duración TEXT ,
)

CREATE TABLE IF NO EXISTS EdiciónTemp(
    id_disco TEXT,
    Año_Edición TEXT,
    País TEXT,
    Formato TEXT,
)

CREATE TABLE IF NO EXISTS DeseaTemp(
    
    Nombre_Usuario TEXT ,
    Título_Disco TEXT ,
    Año_Edición TEXT,
)

CREATE TABLE IF NO EXISTS TieneTemp(
    Nombre_Usuario TEXT,
    Titulo_disco TEXT,
    Año_Publicacion_Disco TEXT,
    Año_Edición TEXT,
    País TEXT,
    Formato TEXT,
    Estado TEXT,
)


SET search_path='nombre del esquema o esquemas utilizados';

\echo 'Cargando datos'
\copy (DiscoTemp) FROM 'csv/discos.csv' DELIMITER ';' CSV HEADER;
\copy (UsuarioTemp) FROM 'csv/usuarios.csv' DELIMITER ';' CSV HEADER;
\copy (CanciónTemp) FROM 'csv/canciones.csv' DELIMITER ';' CSV HEADER;
\copy (EdiciónTemp) FROM 'csv/ediciones.csv' DELIMITER ';' CSV HEADER;
\copy (DeseaTemp) FROM 'csv/usuario_desea_disco.csv' DELIMITER ';' CSV HEADER;
\copy (TieneTemp) FROM 'csv/usuario_tiene_edicion.csv' DELIMITER ';' CSV HEADER;




/*
\echo insertando datos en el esquema final
\ejemplo: insert into Disco values (Título, Año_Publicacion, URL_Grupo, Url_Portada, Nombre_Grupo);



\echo Consulta 1: texto de la consulta
\ej: SELECT Título, Año_Publicacion FROM Disco WHERE Nombre_Grupo = 'The Beatles';

\echo 'Insertando géneros en la tabla Géneros'
INSERT INTO GénerosTemp (Año_Publicación_Disco, Título_Disco, Género)
SELECT Año_Publicacion, Título, regexp_split_to_table(trim(both '[]' from Géneros), ',\s*')
FROM DiscoTemp;


\echo Consulta n:

*/
ROLLBACK;                       -- importante! permite correr el script multiples veces...p