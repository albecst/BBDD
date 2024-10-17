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
    Duración TEXT NOT NULL,
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
    Nombre_Usuario TEXT NOT NULL,
    Estado TEXT NOT NULL,
    CONSTRAINT Tiene_PK PRIMARY KEY (Formato_Edición, Año_Edición, Nombre_Usuario)
    CONSTRAINT EdiciónUsuario_FK FOREIGN KEY (Formato_Edición, Año_Edición, Nombre_Usuario) REFERENCES Edición(Formato), Edición(Año_Edición), Usuario(Nombre_Usuario) MATCH FULL
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


SET search_path='nombre del esquema o esquemas utilizados';

\echo 'Cargando datos'


\echo insertando datos en el esquema final

\echo Consulta 1: texto de la consulta

\echo Consulta n:


ROLLBACK;                       -- importante! permite correr el script multiples veces...p