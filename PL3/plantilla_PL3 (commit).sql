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
    Ano_Publicacion INTEGER NOT NULL,
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
    Duracion TIME,
    Titulo_Disco TEXT NOT NULL,
    Ano_Publicacion_Disco INTEGER NOT NULL,
    CONSTRAINT Cancion_PK PRIMARY KEY (Titulo_Cancion, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Edicion(
    Formato TEXT NOT NULL,
    Ano_Edicion INTEGER NOT NULL,
    Pais TEXT NOT NULL,
    Ano_Publicacion_Disco INTEGER NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    CONSTRAINT Edicion_PK PRIMARY KEY (Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Desea(
    Ano_Publicacion_Disco INTEGER NOT NULL,
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
    Ano_Edicion INTEGER NOT NULL,
    Pais_Edicion TEXT NOT NULL,
    Ano_Publicacion_Disco INTEGER NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    Nombre_Usuario TEXT NOT NULL,
    Estado TEXT NOT NULL,
    CONSTRAINT Tiene_PK PRIMARY KEY (Formato_Edicion, Ano_Edicion, Nombre_Usuario, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco),
    CONSTRAINT EdicionUsuario_FK FOREIGN KEY (Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Edicion(Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT Usuario_FK FOREIGN KEY (Nombre_Usuario) REFERENCES Usuario(Nombre_Usuario) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Generos(
    Ano_Publicacion_Disco INTEGER NOT NULL,
    Genero TEXT NOT NULL,
    Titulo_Disco TEXT NOT NULL,
    CONSTRAINT Generos_PK PRIMARY KEY (Ano_Publicacion_Disco, Titulo_Disco, Genero),
    CONSTRAINT Disco_FK FOREIGN KEY (Ano_Publicacion_Disco, Titulo_Disco) REFERENCES Disco(Ano_Publicacion, Titulo_Disco) MATCH FULL
    ON DELETE RESTRICT ON UPDATE CASCADE
);

\echo 'Creando un esquema temporal'
CREATE TABLE IF NOT EXISTS DiscoTemp(
    id_disco TEXT,
    Titulo TEXT,
    Ano_Publicacion TEXT,
    id_grupo TEXT,
    Nombre_Grupo TEXT,
    URL_Grupo TEXT,
    Generos TEXT,
    Url_Portada TEXT
);

CREATE TABLE IF NOT EXISTS UsuarioTemp(
    Nombre_Completo TEXT,
    Nombre_Usuario TEXT,
    Email TEXT,
    Contrasena TEXT
);

CREATE TABLE IF NOT EXISTS CancionTemp(
    id_disco TEXT,
    Titulo TEXT,
    Duracion TEXT
);

CREATE TABLE IF NOT EXISTS EdicionTemp(
    id_disco TEXT,
    Ano_Edicion TEXT,
    Pais TEXT,
    Formato TEXT
);

CREATE TABLE IF NOT EXISTS DeseaTemp(
    Nombre_Usuario TEXT,
    Titulo_Disco TEXT,
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
--los csv se encuentran en una carpeta llamada "csv" en el mismo directorio que el fichero .sql
\echo 'Cargando datos'
\copy DiscoTemp FROM 'csv/discos.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy UsuarioTemp FROM 'csv/usuarios.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy CancionTemp FROM 'csv/canciones.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy EdicionTemp FROM 'csv/ediciones.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy DeseaTemp FROM 'csv/usuario_desea_disco.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';
\copy TieneTemp FROM 'csv/usuario_tiene_edicion.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' NULL 'NULL';

\echo '\nInsertando datos en el esquema final'

INSERT INTO Grupo (Nombre, URL_Grupo)
SELECT DISTINCT Nombre_Grupo, URL_Grupo
FROM DiscoTemp;

INSERT INTO Usuario (Nombre_Usuario, Nombre, Email, Contrasena)
SELECT DISTINCT Nombre_Usuario, Nombre_Completo, Email, Contrasena
FROM UsuarioTemp;

INSERT INTO Disco (Ano_Publicacion, Titulo_Disco, Url_Portada, Nombre_Grupo)
SELECT DISTINCT ON (Ano_Publicacion, Titulo) Ano_Publicacion::INTEGER, Titulo, Url_Portada, Nombre_Grupo
FROM DiscoTemp;

INSERT INTO Cancion (Titulo_Cancion, Duracion, Titulo_Disco, Ano_Publicacion_Disco)
SELECT DISTINCT ON (CancionTemp.Titulo, Ano_Publicacion, DiscoTemp.Titulo) CancionTemp.Titulo,
       MAKE_INTERVAL(mins => SPLIT_PART(CancionTemp.Duracion, ':', 1)::INTEGER,
                     secs => SPLIT_PART(CancionTemp.Duracion, ':', 2)::INTEGER)::TIME,
       DiscoTemp.Titulo,
       DiscoTemp.Ano_Publicacion::INTEGER
FROM CancionTemp
JOIN DiscoTemp ON CancionTemp.id_disco = DiscoTemp.id_disco;

INSERT INTO Edicion (Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco)
SELECT DISTINCT ON  (Formato, Ano_Edicion, Pais, Ano_Publicacion, Titulo)Formato, Ano_Edicion::INTEGER, Pais, DiscoTemp.Ano_Publicacion::INTEGER, DiscoTemp.Titulo
FROM EdicionTemp
JOIN DiscoTemp ON EdicionTemp.id_disco = DiscoTemp.id_disco;

INSERT INTO Desea (Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario)
SELECT DISTINCT ON (Titulo_Disco, Nombre_Usuario) Disco.Ano_Publicacion::INTEGER, Disco.Titulo_Disco, DeseaTemp.Nombre_Usuario
FROM DeseaTemp JOIN Usuario ON DeseaTemp.Nombre_Usuario = Usuario.Nombre_Usuario JOIN Disco ON DeseaTemp.Titulo_Disco = Disco.Titulo_Disco;


INSERT INTO Tiene (Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario, Estado)
SELECT DISTINCT ON (Formato, Ano_Edicion, Nombre_Usuario, Pais, Ano_Publicacion_Disco, Titulo_Disco) Formato, Ano_Edicion::INTEGER, Pais, Ano_Publicacion_Disco::INTEGER, Titulo_Disco, TieneTemp.Nombre_Usuario, Estado
FROM TieneTemp JOIN Usuario ON TieneTemp.Nombre_Usuario = Usuario.Nombre_Usuario;

INSERT INTO Generos (Ano_Publicacion_Disco, Genero, Titulo_Disco)
SELECT DISTINCT Ano_Publicacion::INTEGER, regexp_split_to_table(trim(both '[]' from Generos), ',\s*'), Titulo
FROM DiscoTemp;

\echo Consulta 1: Mostrar los discos que tengan más de 5 canciones

SELECT Titulo_Disco 
FROM Disco 
WHERE (SELECT COUNT(*) 
FROM Cancion 
WHERE Disco.Ano_Publicacion = Cancion.Ano_Publicacion_Disco AND Disco.Titulo_Disco = Cancion.Titulo_Disco) > 5;

\echo Consulta 2: Mostrar los vinilos que tiene el usuario Juan García Gómez junto con el título del disco, y el país y año de edición del mismo 
SELECT Titulo_Disco, Pais_Edicion, Ano_Edicion 
FROM Tiene JOIN Usuario ON Tiene.Nombre_Usuario = Usuario.Nombre_Usuario 
WHERE Usuario.Nombre = 'Juan García Gómez' AND Tiene.Formato_Edicion = 'Vinyl';

\echo Consulta 3: Disco con mayor duración de la colección.
WITH DuracionDiscos (Duracion,Titulo_Disco) AS 
(SELECT SUM(Cancion.Duracion), Disco.Titulo_Disco 
FROM Cancion JOIN Disco ON Disco.Titulo_Disco = Cancion.Titulo_Disco 
GROUP BY Disco.Titulo_Disco)
SELECT Titulo_Disco, Duracion FROM DuracionDiscos WHERE Duracion = (SELECT MAX(Duracion) FROM DuracionDiscos);

\echo Consulta 4: De los discos que tiene en su lista de deseos el usuario Juan García Gómez, indicar el nombre de los grupos musicales que los interpretan. 
SELECT Nombre_Grupo 
FROM Disco JOIN Desea ON Disco.Ano_Publicacion = Desea.Ano_Publicacion_Disco AND Disco.Titulo_Disco = Desea.Titulo_Disco 
JOIN Usuario ON Desea.Nombre_Usuario = Usuario.Nombre_Usuario 
WHERE Usuario.Nombre = 'Juan García Gómez'; 

\echo Consulta 5: Mostrar los discos publicados entre 1970 y 1972 junto con sus ediciones ordenados por el año de publicación. 
SELECT Disco.Titulo_Disco, Disco.Ano_Publicacion, Edicion.Ano_Edicion
FROM Disco JOIN Edicion ON Disco.Titulo_Disco = Edicion.Titulo_Disco 
WHERE Disco.Ano_Publicacion >= 1970 AND Disco.Ano_Publicacion <= 1972
ORDER BY Disco.Ano_Publicacion;

\echo Consulta 6: Listar el nombre de todos los grupos que han publicado discos del género ‘Electronic’.
SELECT DISTINCT Grupo.Nombre
FROM Grupo JOIN Disco ON Grupo.Nombre = Disco.Nombre_Grupo 
JOIN Generos ON Disco.Titulo_Disco = Generos.Titulo_Disco
 WHERE Generos.Genero LIKE '%Electronic%';

\echo Consulta 7: Lista de discos con la duración total del mismo, editados antes del año 2000. 
SELECT Disco.Titulo_Disco, SUM(Cancion.Duracion)
FROM Disco JOIN Cancion ON Disco.Titulo_Disco = Cancion.Titulo_Disco 
WHERE Disco.Ano_Publicacion < 2000 GROUP BY Disco.Titulo_Disco;

\echo Consulta 8: Lista de ediciones de discos deseados por el usuario Lorena Sáez Pérez que tiene el usuario Juan García Gómez
WITH Deseados_Lorena(Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco ) AS
(SELECT Formato, Ano_Edicion, Pais, Edicion.Ano_Publicacion_Disco, Edicion.Titulo_Disco 
FROM Desea 
JOIN Usuario ON Desea.Nombre_Usuario = Usuario.Nombre_Usuario
JOIN Edicion ON Desea.Ano_Publicacion_Disco = Edicion.Ano_Publicacion_Disco AND Desea.Titulo_Disco = Edicion.Titulo_Disco
WHERE Desea.Nombre_Usuario = 'Lorena Sáez Pérez')

SELECT dl.Formato, dl.Ano_Edicion, Pais, dl.Ano_Publicacion_Disco, dl.Titulo_Disco 
FROM Tiene
JOIN Usuario ON Tiene.Nombre_Usuario = Usuario.Nombre_Usuario
JOIN Deseados_Lorena dl ON dl.Ano_Publicacion_Disco = Tiene.Ano_Publicacion_Disco AND dl.Titulo_Disco = Tiene.Titulo_Disco
WHERE Tiene.Nombre_Usuario = 'Juan García Gómez';

\echo Consulta 9: Lista todas las ediciones de los discos que tiene el usuario Gómez García en un estado NM o M. 
SELECT Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco
FROM Tiene 
JOIN Usuario ON Tiene.Nombre_Usuario = Usuario.Nombre_Usuario 
WHERE Usuario.Nombre LIKE '%Gómez García' AND (Estado = 'NM' OR Estado = 'M');

\echo Consulta 10: Listar todos los usuarios junto al número de ediciones que tiene de todos los discos junto al año de lanzamiento de su disco más antiguo, el año de lanzamiento de su disco más nuevo, y el año medio de todos sus discos de su colección
SELECT Nombre_Usuario, COUNT(*), MIN(Ano_Edicion), MAX(Ano_Edicion), AVG(Ano_Edicion) 
FROM Tiene GROUP BY Nombre_Usuario;

\echo Consulta 11: Listar el nombre de los grupos que tienen más de 5 ediciones de sus discos en la base de datos 
SELECT Nombre_Grupo 
FROM Disco JOIN Edicion ON Disco.Ano_Publicacion = Edicion.Ano_Publicacion_Disco AND Disco.Titulo_Disco = Edicion.Titulo_Disco 
GROUP BY Nombre_Grupo HAVING COUNT(*) > 5;

\echo Consulta 12: Lista el usuario que más discos, contando todas sus ediciones tiene en la base de datos
SELECT Nombre_Usuario 
FROM Tiene GROUP BY Nombre_Usuario 
HAVING COUNT(*) = (SELECT MAX(NumDiscos) FROM (SELECT COUNT(*) AS NumDiscos FROM Tiene GROUP BY Nombre_Usuario) AS NumDiscos); 

ROLLBACK;