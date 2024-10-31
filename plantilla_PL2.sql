\pset pager off

SET client_encoding = 'UTF8';

BEGIN;
\echo 'creando el esquema para la BBDD de discos'

CREATE TABLE IF NOT EXISTS Grupo(
    Nombre TEXT NOT NULL,
    URL_Grupo TEXT NOT NULL,
    CONSTRAINT Nombre_PK PRIMARY KEY (Nombre)
);

CREATE TABLE IF NOT EXISTS Disco(
    Ano_Publicacion TEXT NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    Url_Portada TEXT,
    Nombre_Grupo TEXT NOT NULL,
    CONSTRAINT Disco_PK PRIMARY KEY (Ano_Publicacion, Titulo_Disco),
    CONSTRAINT Grupo_FK FOREIGN KEY (Nombre_Grupo) REFERENCES Grupo(Nombre) MATCH FULL 
    ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Usuario(
    Nombre_Usuario TEXT NOT NULL,
    Nombre TEXT NOT NULL,
    Email TEXT NOT NULL,
    Contrasena TEXT NOT NULL,
    CONSTRAINT Usuario_PK PRIMARY KEY (Nombre_Usuario)
);

CREATE TABLE IF NOT EXISTS Cancion(
    Titulo_Cancion TEXT NOT NULL,
    Duracion TEXT , --será TIME
    Titulo_Disco TEXT NOT NULL,
    Ano_Publicacion_Disco TEXT NOT NULL,
    CONSTRAINT Cancion_PK PRIMARY KEY (Titulo_Cancion, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Edicion(
    Formato TEXT NOT NULL,
    Ano_Edicion TEXT NOT NULL,
    Pais TEXT NOT NULL,
    Ano_Publicacion_Disco TEXT NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    CONSTRAINT Edicion_PK PRIMARY KEY (Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Desea(
    Ano_Publicacion_Disco TEXT NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    Nombre_Usuario TEXT NOT NULL,
    CONSTRAINT Desea_PK PRIMARY KEY (Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT Usuario_FK FOREIGN KEY (Nombre_Usuario) REFERENCES Usuario(Nombre_Usuario) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Tiene(
    Formato_Edicion TEXT NOT NULL,
    Ano_Edicion TEXT NOT NULL,
    Pais_Edicion TEXT NOT NULL,
    Ano_Publicacion_Disco TEXT NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    Nombre_Usuario TEXT NOT NULL,
    Estado TEXT NOT NULL,
    CONSTRAINT Tiene_PK PRIMARY KEY (Formato_Edicion, Ano_Edicion, Nombre_Usuario, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT EdicionUsuario_FK FOREIGN KEY (Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Edicion(Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT Usuario_FK FOREIGN KEY (Nombre_Usuario) REFERENCES Usuario(Nombre_Usuario) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Géneros(
    Ano_Publicacion_Disco TEXT NOT NULL,
    Género TEXT NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    CONSTRAINT Géneros_PK PRIMARY KEY (Ano_Publicacion_Disco, Titulo_Disco, Género),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

\echo 'Creando un esquema temporal'
CREATE TABLE IF NOT EXISTS DiscoTemp(
    id_disco TEXT,
    Titulo TEXT ,
    Ano_Publicacion TEXT ,
    id_grupo TEXT,
    Nombre_Grupo TEXT ,
    URL_Grupo TEXT,
    Generos TEXT ,
    Url_Portada TEXT 
);


CREATE TABLE IF NOT EXISTS UsuarioTemp(
    Nombre_Completo TEXT ,
    Nombre_Usuario TEXT ,
    Email TEXT ,
    Contrasena TEXT 
);

CREATE TABLE IF NOT EXISTS CancionTemp(
    id_disco TEXT,
    Titulo TEXT ,
    Duracion TEXT 
);

CREATE TABLE IF NOT EXISTS EdicionTemp(
    id_disco TEXT,
    Ano_Edicion TEXT,
    Pais TEXT,
    Formato TEXT
);

CREATE TABLE IF NOT EXISTS DeseaTemp(
    
    Nombre_Usuario TEXT ,
    Titulo_Disco TEXT ,
    Ano_Edicion TEXT
);

CREATE TABLE IF NOT EXISTS TieneTemp(
    Nombre_Usuario TEXT,
    Titulo_Disco TEXT,
    Ano_Publicacion_Disco TEXT,
    Ano_Edicion TEXT,
    Pais TEXT,
    Formato TEXT,
    Estado TEXT
);


--SET search_path='nombre del esquema o esquemas utilizados';

\echo 'Cargando datos'
\copy DiscoTemp FROM 'csv/discos.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL'; --por si hay un null en el csv
\copy UsuarioTemp FROM 'csv/usuarios.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy CancionTemp FROM 'csv/canciones.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy EdicionTemp FROM 'csv/ediciones.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy DeseaTemp FROM 'csv/usuario_desea_disco.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy TieneTemp FROM 'csv/usuario_tiene_edicion.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';


\echo '\nInsertando datos en el esquema final'

INSERT INTO Grupo (Nombre, URL_Grupo) 
SELECT DISTINCT Nombre_Grupo, URL_Grupo 
FROM DiscoTemp;

INSERT INTO Usuario (Nombre_Usuario,Nombre,Email,Contrasena) 
SELECT DISTINCT Nombre_Completo, Nombre_Usuario, Email, Contrasena 
FROM UsuarioTemp;

INSERT INTO Disco (Ano_Publicacion, Titulo_Disco, Url_Portada, Nombre_Grupo)
SELECT DISTINCT Ano_Publicacion, Titulo, Url_Portada, Nombre_Grupo
FROM DiscoTemp
ON CONFLICT (Ano_Publicacion, Titulo_Disco) DO NOTHING;

INSERT INTO Cancion (Titulo_Cancion, Duracion, Titulo_Disco, Ano_Publicacion_Disco)
SELECT CancionTemp.Titulo, CancionTemp.Duracion, DiscoTemp.Titulo, DiscoTemp.Ano_Publicacion
FROM CancionTemp
JOIN DiscoTemp ON CancionTemp.id_disco = DiscoTemp.id_disco
ON CONFLICT (Titulo_Cancion, Ano_Publicacion_Disco, Titulo_Disco) DO NOTHING; --por si hay canciones repetidas, para que no se incluyan

INSERT INTO Edicion (Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco)
SELECT DISTINCT Formato, Ano_Edicion, Pais, DiscoTemp.Ano_Publicacion, DiscoTemp.Titulo
FROM EdicionTemp
JOIN DiscoTemp ON EdicionTemp.id_disco = DiscoTemp.id_disco
ON CONFLICT (Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco) DO NOTHING;


INSERT INTO Desea (Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario)
SELECT DeseaTemp.Ano_Edicion, DeseaTemp.Titulo_Disco, DeseaTemp.Nombre_Usuario
FROM DeseaTemp
ON CONFLICT (Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario) DO NOTHING;




/*
SELECT DISTINCT * 
FROM DeseaTemp
INNER JOIN DiscoTemp ON DeseaTemp.Titulo_Disco = Titulo;*/


--'insert into Disco values (Titulo, Ano_Publicacion, URL_Grupo, Url_Portada, Nombre_Grupo);'


/*
\echo Consulta 1: texto de la consulta
\ej: SELECT Titulo, Ano_Publicacion FROM Disco WHERE Nombre_Grupo = 'The Beatles';

\echo 'Insertando géneros en la tabla Géneros'
INSERT INTO GénerosTemp (Ano_Publicacion_Disco, Titulo_Disco, Género)
SELECT Ano_Publicacion, Titulo, regexp_split_to_table(trim(both '[]' from Géneros), ',\s*')
FROM DiscoTemp;


\echo Consulta n:
*/

ROLLBACK;                       -- importante! permite correr el script multiples veces...p