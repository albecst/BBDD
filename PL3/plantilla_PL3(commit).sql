\pset pager off

SET client_encoding = 'UTF8';

BEGIN;
/*
DROP TABLE IF EXISTS base_discos.Generos CASCADE;
DROP TABLE IF EXISTS base_discos.Tiene CASCADE;
DROP TABLE IF EXISTS base_discos.Desea CASCADE;
DROP TABLE IF EXISTS base_discos.Edicion CASCADE;
DROP TABLE IF EXISTS base_discos.Cancion CASCADE;
DROP TABLE IF EXISTS base_discos.Usuario CASCADE;
DROP TABLE IF EXISTS base_discos.Disco CASCADE;
DROP TABLE IF EXISTS base_discos.Grupo CASCADE;
DROP TABLE IF EXISTS temp.DiscoTemp CASCADE;
DROP TABLE IF EXISTS temp.UsuarioTemp CASCADE;
DROP TABLE IF EXISTS temp.CancionTemp CASCADE;
DROP TABLE IF EXISTS temp.EdicionTemp CASCADE;
DROP TABLE IF EXISTS temp.DeseaTemp CASCADE;
DROP TABLE IF EXISTS temp.TieneTemp CASCADE;
DROP TABLE IF EXISTS auditoria CASCADE;*/


\echo 'creando el esquema para la BBDD de discos'

CREATE SCHEMA base_discos;
CREATE SCHEMA temp;

CREATE TABLE IF NOT EXISTS base_discos.Grupo(
    Nombre TEXT NOT NULL,
    URL_Grupo TEXT NOT NULL,
    CONSTRAINT Nombre_PK PRIMARY KEY (Nombre)
);

CREATE TABLE IF NOT EXISTS base_discos.Disco(
    Ano_Publicacion INTEGER NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    Url_Portada TEXT,
    Nombre_Grupo TEXT NOT NULL,
    CONSTRAINT Disco_PK PRIMARY KEY (Ano_Publicacion, Titulo_Disco),
    CONSTRAINT Grupo_FK FOREIGN KEY (Nombre_Grupo) REFERENCES base_discos.Grupo(Nombre) MATCH FULL 
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS base_discos.Usuario(
    Nombre_Usuario TEXT NOT NULL,
    Nombre TEXT NOT NULL,
    Email TEXT NOT NULL,
    Contrasena TEXT NOT NULL,
    CONSTRAINT Usuario_PK PRIMARY KEY (Nombre_Usuario)
);

CREATE TABLE IF NOT EXISTS base_discos.Cancion(
    Titulo_Cancion TEXT NOT NULL,
    Duracion TIME,
    Titulo_Disco TEXT NOT NULL,
    Ano_Publicacion_Disco INTEGER NOT NULL,
    CONSTRAINT Cancion_PK PRIMARY KEY (Titulo_Cancion, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES base_discos.Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS base_discos.Edicion(
    Formato TEXT NOT NULL,
    Ano_Edicion INTEGER NOT NULL,
    Pais TEXT NOT NULL,
    Ano_Publicacion_Disco INTEGER NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    CONSTRAINT Edicion_PK PRIMARY KEY (Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES base_discos.Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS base_discos.Desea(
    Ano_Publicacion_Disco INTEGER NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    Nombre_Usuario TEXT NOT NULL,
    CONSTRAINT Desea_PK PRIMARY KEY (Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES base_discos.Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT Usuario_FK FOREIGN KEY (Nombre_Usuario) REFERENCES base_discos.Usuario(Nombre_Usuario) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS base_discos.Tiene(
    Formato_Edicion TEXT NOT NULL,
    Ano_Edicion INTEGER NOT NULL,
    Pais_Edicion TEXT NOT NULL,
    Ano_Publicacion_Disco INTEGER NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    Nombre_Usuario TEXT NOT NULL,
    Estado TEXT NOT NULL,
    CONSTRAINT Tiene_PK PRIMARY KEY (Formato_Edicion, Ano_Edicion, Nombre_Usuario, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT EdicionUsuario_FK FOREIGN KEY (Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco) REFERENCES base_discos.Edicion(Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT Usuario_FK FOREIGN KEY (Nombre_Usuario) REFERENCES base_discos.Usuario(Nombre_Usuario) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS base_discos.Generos(
    Ano_Publicacion_Disco INTEGER NOT NULL,
    Genero TEXT NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    CONSTRAINT Generos_PK PRIMARY KEY (Ano_Publicacion_Disco, Titulo_Disco, Genero),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES base_discos.Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

\echo 'Creando un esquema temporal'
CREATE TABLE IF NOT EXISTS temp.DiscoTemp(
    id_disco TEXT,
    Titulo TEXT,
    Ano_Publicacion TEXT,
    id_grupo TEXT,
    Nombre_Grupo TEXT,
    URL_Grupo TEXT,
    Generos TEXT,
    Url_Portada TEXT
);

CREATE TABLE IF NOT EXISTS temp.UsuarioTemp(
    Nombre_Completo TEXT,
    Nombre_Usuario TEXT,
    Email TEXT,
    Contrasena TEXT
);

CREATE TABLE IF NOT EXISTS temp.CancionTemp(
    id_disco TEXT,
    Titulo TEXT,
    Duracion TEXT
);

CREATE TABLE IF NOT EXISTS temp.EdicionTemp(
    id_disco TEXT,
    Ano_Edicion TEXT,
    Pais TEXT,
    Formato TEXT
);

CREATE TABLE IF NOT EXISTS temp.DeseaTemp(
    Nombre_Usuario TEXT,
    Titulo_Disco TEXT,
    Ano_Edicion TEXT
);

CREATE TABLE IF NOT EXISTS temp.TieneTemp(
    Nombre_Usuario TEXT,
    Titulo_Disco TEXT,
    Ano_Publicacion_Disco TEXT,
    Ano_Edicion TEXT,
    Pais TEXT,
    Formato TEXT,
    Estado TEXT
);
--los csv se encuentran en una carpeta llamada "csv" en el mismo directorio que el fichero .sql
\echo 'Cargando datos'
\copy temp.DiscoTemp FROM 'csv/discos.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy temp.UsuarioTemp FROM 'csv/usuarios.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy temp.CancionTemp FROM 'csv/canciones.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy temp.EdicionTemp FROM 'csv/ediciones.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy temp.DeseaTemp FROM 'csv/usuario_desea_disco.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy temp.TieneTemp FROM 'csv/usuario_tiene_edicion.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';

\echo '\nInsertando datos en el esquema final'

INSERT INTO base_discos.Grupo (Nombre, URL_Grupo)
SELECT DISTINCT Nombre_Grupo, URL_Grupo
FROM temp.DiscoTemp;

INSERT INTO base_discos.Usuario (Nombre_Usuario, Nombre, Email, Contrasena)
SELECT DISTINCT Nombre_Usuario, Nombre_Completo, Email, Contrasena
FROM temp.UsuarioTemp;

INSERT INTO base_discos.Disco (Ano_Publicacion, Titulo_Disco, Url_Portada, Nombre_Grupo)
SELECT DISTINCT ON (Ano_Publicacion, Titulo) Ano_Publicacion::INTEGER, Titulo, Url_Portada, Nombre_Grupo
FROM temp.DiscoTemp;

INSERT INTO base_discos.Cancion (Titulo_Cancion, Duracion, Titulo_Disco, Ano_Publicacion_Disco)
SELECT DISTINCT ON (temp.CancionTemp.Titulo, Ano_Publicacion, temp.DiscoTemp.Titulo) temp.CancionTemp.Titulo,
       MAKE_INTERVAL(mins => SPLIT_PART(temp.CancionTemp.Duracion, ':', 1)::INTEGER,
                     secs => SPLIT_PART(temp.CancionTemp.Duracion, ':', 2)::INTEGER)::TIME,
       temp.DiscoTemp.Titulo,
       temp.DiscoTemp.Ano_Publicacion::INTEGER
FROM temp.CancionTemp
JOIN temp.DiscoTemp ON temp.CancionTemp.id_disco = temp.DiscoTemp.id_disco;

INSERT INTO base_discos.Edicion (Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco)
SELECT DISTINCT ON  (Formato, Ano_Edicion, Pais, Ano_Publicacion, Titulo)Formato, Ano_Edicion::INTEGER, Pais, temp.DiscoTemp.Ano_Publicacion::INTEGER, temp.DiscoTemp.Titulo
FROM temp.EdicionTemp
JOIN temp.DiscoTemp ON temp.EdicionTemp.id_disco = temp.DiscoTemp.id_disco;

INSERT INTO base_discos.Desea (Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario)
SELECT DISTINCT ON (Titulo_Disco, Nombre_Usuario) base_discos.Disco.Ano_Publicacion::INTEGER, base_discos.Disco.Titulo_Disco, temp.DeseaTemp.Nombre_Usuario
FROM temp.DeseaTemp JOIN base_discos.Usuario ON temp.DeseaTemp.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario JOIN base_discos.Disco ON temp.DeseaTemp.Titulo_Disco = base_discos.Disco.Titulo_Disco;


INSERT INTO base_discos.Tiene (Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario, Estado)
SELECT DISTINCT ON (Formato, Ano_Edicion, Nombre_Usuario, Pais, Ano_Publicacion_Disco, Titulo_Disco) Formato, Ano_Edicion::INTEGER, Pais, Ano_Publicacion_Disco::INTEGER, Titulo_Disco, temp.TieneTemp.Nombre_Usuario, Estado
FROM temp.TieneTemp JOIN base_discos.Usuario ON temp.TieneTemp.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario;

INSERT INTO base_discos.Generos (Ano_Publicacion_Disco, Genero, Titulo_Disco)
SELECT DISTINCT Ano_Publicacion::INTEGER, regexp_split_to_table(trim(both '[]' from Generos), ',\s*'), Titulo
FROM temp.DiscoTemp;
/*

\echo Consulta 1: Mostrar los discos que tengan más de 5 canciones

SELECT Titulo_Disco 
FROM base_discos.Disco 
WHERE (SELECT COUNT(*) 
FROM base_discos.Cancion 
WHERE base_discos.Disco.Ano_Publicacion = base_discos.Cancion.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco) > 5;

\echo Consulta 2: Mostrar los vinilos que tiene el usuario Juan García Gómez junto con el título del disco, y el país y año de edición del mismo 
SELECT Titulo_Disco, Pais_Edicion, Ano_Edicion 
FROM base_discos.Tiene JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario 
WHERE base_discos.Usuario.Nombre = 'Juan García Gómez' AND base_discos.Tiene.Formato_Edicion = 'Vinyl';

\echo Consulta 3: Disco con mayor duración de la colección.
WITH DuracionDiscos (Duracion,Titulo_Disco) AS 
(SELECT SUM(base_discos.Cancion.Duracion), base_discos.Disco.Titulo_Disco 
FROM base_discos.Cancion JOIN base_discos.Disco ON base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco 
GROUP BY base_discos.Disco.Titulo_Disco)
SELECT Titulo_Disco, Duracion FROM DuracionDiscos WHERE Duracion = (SELECT MAX(Duracion) FROM DuracionDiscos);

\echo Consulta 4: De los discos que tiene en su lista de deseos el usuario Juan García Gómez, indicar el nombre de los grupos musicales que los interpretan. 
SELECT Nombre_Grupo 
FROM base_discos.Disco JOIN base_discos.Desea ON base_discos.Disco.Ano_Publicacion = base_discos.Desea.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Desea.Titulo_Disco 
JOIN base_discos.Usuario ON base_discos.Desea.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario 
WHERE base_discos.Usuario.Nombre = 'Juan García Gómez'; 

\echo Consulta 5: Mostrar los discos publicados entre 1970 y 1972 junto con sus ediciones ordenados por el año de publicación. 
SELECT base_discos.Disco.Titulo_Disco, base_discos.Disco.Ano_Publicacion, base_discos.Edicion.Ano_Edicion
FROM base_discos.Disco JOIN base_discos.Edicion ON base_discos.Disco.Titulo_Disco = base_discos.Edicion.Titulo_Disco 
WHERE base_discos.Disco.Ano_Publicacion >= 1970 AND base_discos.Disco.Ano_Publicacion <= 1972
ORDER BY base_discos.Disco.Ano_Publicacion;

\echo Consulta 6: Listar el nombre de todos los grupos que han publicado discos del género ‘Electronic’.
SELECT DISTINCT base_discos.Grupo.Nombre
FROM base_discos.Grupo JOIN base_discos.Disco ON base_discos.Grupo.Nombre = base_discos.Disco.Nombre_Grupo 
JOIN base_discos.Generos ON base_discos.Disco.Titulo_Disco = base_discos.Generos.Titulo_Disco
 WHERE base_discos.Generos.Genero LIKE '%Electronic%';

\echo Consulta 7: Lista de discos con la duración total del mismo, editados antes del año 2000. 
SELECT base_discos.Disco.Titulo_Disco, SUM(base_discos.Cancion.Duracion)
FROM base_discos.Disco JOIN base_discos.Cancion ON base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco 
WHERE base_discos.Disco.Ano_Publicacion < 2000 GROUP BY base_discos.Disco.Titulo_Disco;

\echo Consulta 8: Lista de ediciones de discos deseados por el usuario Lorena Sáez Pérez que tiene el usuario Juan García Gómez
WITH Deseados_Lorena(Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco ) AS
(SELECT Formato, Ano_Edicion, Pais, base_discos.Edicion.Ano_Publicacion_Disco, base_discos.Edicion.Titulo_Disco 
FROM base_discos.Desea 
JOIN base_discos.Usuario ON base_discos.Desea.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario
JOIN base_discos.Edicion ON base_discos.Desea.Ano_Publicacion_Disco = base_discos.Edicion.Ano_Publicacion_Disco AND base_discos.Desea.Titulo_Disco = base_discos.Edicion.Titulo_Disco
WHERE base_discos.Desea.Nombre_Usuario = 'Lorena Sáez Pérez')

SELECT dl.Formato, dl.Ano_Edicion, Pais, dl.Ano_Publicacion_Disco, dl.Titulo_Disco 
FROM base_discos.Tiene
JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario
JOIN Deseados_Lorena dl ON dl.Ano_Publicacion_Disco = base_discos.Tiene.Ano_Publicacion_Disco AND dl.Titulo_Disco = base_discos.Tiene.Titulo_Disco
WHERE base_discos.Tiene.Nombre_Usuario = 'Juan García Gómez';

\echo Consulta 9: Lista todas las ediciones de los discos que tiene el usuario Gómez García en un estado NM o M. 
SELECT Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco
FROM base_discos.Tiene 
JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario 
WHERE base_discos.Usuario.Nombre LIKE '%Gómez García' AND (Estado = 'NM' OR Estado = 'M');

\echo Consulta 10: Listar todos los usuarios junto al número de ediciones que tiene de todos los discos junto al año de lanzamiento de su disco más antiguo, el año de lanzamiento de su disco más nuevo, y el año medio de todos sus discos de su colección
SELECT Nombre_Usuario, COUNT(*), MIN(Ano_Edicion), MAX(Ano_Edicion), AVG(Ano_Edicion) 
FROM base_discos.Tiene GROUP BY Nombre_Usuario;

\echo Consulta 11: Listar el nombre de los grupos que tienen más de 5 ediciones de sus discos en la base de datos 
SELECT Nombre_Grupo 
FROM base_discos.Disco JOIN base_discos.Edicion ON base_discos.Disco.Ano_Publicacion = base_discos.Edicion.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Edicion.Titulo_Disco 
GROUP BY Nombre_Grupo HAVING COUNT(*) > 5;

\echo Consulta 12: Lista el usuario que más discos, contando todas sus ediciones tiene en la base de datos
SELECT Nombre_Usuario 
FROM base_discos.Tiene GROUP BY Nombre_Usuario 
HAVING COUNT(*) = (SELECT MAX(NumDiscos) FROM (SELECT COUNT(*) AS NumDiscos FROM base_discos.Tiene GROUP BY Nombre_Usuario) AS NumDiscos); 
*/
--ROLLBACK;
COMMIT;