1. Mostrar código de asignatura y nombre de asignaturas que sean de Base de Datos
SELECT cod_asignatura, nombre_asignatura
FROM asignaturas
WHERE nombre_asignatura LIKE '%Base de Datos%';

2. Profesores que coordinan alguna asignatura


3. Obtener nombre y apellidos de todos los profesores que imparten alguna asignatura de Base de Datos
SELECT nombre_profesor, apellidos_profesor
FROM Profesores P JOIN Imparten I ON P.IDP = I.IDP JOIN Asignaturas A ON I.COD_ASIGNATURA = A.COD_ASIGNATURA
WHERE A.Nombre LIKE '%Base de Datos%';

4. Despachos sin profesor asignado
SELECT D.N_despacho
FROM Despachos D LEFT JOIN Profesores P ON D.N_despacho = P.N_despacho
WHERE P.IDP IS NULL;

5. Borrar el despacho N342 y los profesores que tengan asignado ese despacho
DELETE FROM Despachos
WHERE N_despacho = 'N342'

DELETE FROM Profesores
WHERE N_despacho = 'N342'

6. Mostar el Número de despachos por planta
SELECT D.Planta, COUNT(D.N_despacho)
FROM Despachos D
GROUP BY (D.Planta)

7. Mostrar el Número de cada despacho junto con el número de profesores que hay en dichos despachos
SELECT N_despacho, COUNT(P.IDP)
FROM Profesores P
GROUP BY (P.N_despacho);

8. Mostrar el número de los despachos que están ocupado por más de un profesor
SELECT P.N_despacho
FROM Profesores P
GROUP BY (P.N_despacho)
HAVING COUNT(P.IDP) > 1

9. Mostrar el nombre y apellidos de los profesores que coordinan alguna asignatura
SELECT P.Nombre, P.Apellidos
FROM Profesores P JOIN Asignaturas A ON A.IDP = P.IDP

10. Mostrar el nombre de los profesores que coordinan asignaturas junto a la asignatura que coordinan y el número de despacho que tienen
SELECT P.Nombre, P.Apellido, A.Nombre, P.N_despacho
FROM Profesores P JOIN Asignaturas A ON A.IDP = P.IDP

11. Isertar un profesor y un despacho con los siguientes valores: Idf=8, Alberto Garcés, sin despacho asignado // Despacho N342, zona Norte, planta 3, pasillo 4, puerta 2
INSERT INTO Profesores VALUES(8, 'Alberto', 'Garcés', NULL);
INSERT INTO Despachos VALUES('N342', 3, 4, 2);

12. Mostrar despachos vacíos que no tengan ningún profesor asignado
SELECT D.N_despacho
FROM Despachos D LEFT JOIN Profesores P ON D.N_despacho = P.N_despacho
WHERE P.IDP IS NULL;

13. Modificar el número de despacho N342 a aquellos profesores que no tengan despacho asignado
UPDATE Profesores P
SET P.N_despacho = 'N342'
WHERE P.N_despacho IS NULL;


14. Crear una vista con todas las asignaturas el nombre y apellidos del profesor que la coordina y el número de despacho que ocupa
CREATE VIEW Vista(A.Nombre, P.Nombre, P.Apellidos, P.N_despacho) AS
    SELECT A.Nombre, P.Nombre, P.Apellidos, P.N_despacho
    FROM Asignaturas A JOIN Profesores P ON A.IDP = P.IDP

---
---
---
---
---
-- CONGRESOS --
1. Mostrar las salas existentes: nombre, capacidad y precio.
SELECT Sa.Nombre, Sa.Capacidad, Sa.Precio
FROM Sala Sa

2. Mostrar los ponentes que participan en el congreso: nombre y organización.
SELECT P.Nombre, P.Organ
FROM Ponentes P

3. Mostrar los temas que se tratan en el congreso, es decir los nombres diferentes, no repetidos, de sesiones.
SELECT DISTINCT Se.Titsesion
FROM Sesion Se

4. Mostrar los ponentes de la empresa LOGIC ordenados por dni: dni, nombre y puesto.
SELECT Ponente.DNI, Ponente.Nombre, Ponente.Puesto
FROM Ponente
WHERE Ponente.Organ = 'LOGIC'
ORDER BY Ponente.DNI

5. Mostrar los ponentes de Italia que trabajen en la empresa TERMICOMP ordenados de
forma descendente por nombre: nombre y puesto.
SELECT Ponente.Nombre, Ponente.Puesto
FROM Ponente
WHERE Ponente.Pais = 'Italia' AND Ponente.Organ = 'TERMICOMP'
ORDER BY Ponente.Nombre DESC

6. Mostrar las ponencias que se presentan los días 3 y 4 de junio de 2006: código de la
ponencia y título.
SELECT Ponencia.CodPonen, Ponencia.Titponen
FROM Ponencia  JOIN Sesion Se ON Se.Codponencia = Ponencia.CodPonencia
WHERE Se.Fecha = '2006-06-03' OR Se.Fecha = '2006-06-04';


7. Mostrar el país, empresa y nombre de los ponentes franceses e italianos, ordenado
alfabéticamente por país, empresa y nombre.
SELECT Ponente.Pais, Ponente.Organ, Ponente.Nombre
FROM Ponente
WHERE Ponente.Pais IN('Francia', 'Italia')
ORDER BY Ponente.Pais, Ponente.Organ, Ponente.Nombre

8. Mostrar las sesiones 3 y 4 de los días 2 y 4 de junio de 2006, ordenadas
alfabéticamente por nombre de la sala donde se celebran: nombre de la sala, día y
número de sesión. Mostrar la fecha en formato ddmm-aaaa.
SELECT Sa.Nombre, TO_CHAR(Se.Fecha, 'DDMM-YYYY') AS Fecha, Se.N_Sesion
FROM Sala Sa JOIN Sesion Se ON Sa.NumSala = Se.NumSala
WHERE Se.N_Sesion IN (3, 4) AND Se.Fecha IN ('2006-06-02','2006-06-04')
ORDER BY Sa.Nombre

9. Mostrar las salas cuyo nombre empiece por ‘S’, excepto la sala ‘SAUCE’, ordenadas por
capacidad: nombre y capacidad.
SELECT Sa.Nombre, Sa.Capacidad
FROM Sala Sa
WHERE Sa.Nombre LIKE 'S%' AND Sa.Nombre NOT LIKE 'SAUCE'
ORDER BY Sa.Capacidad

10. Mostrar los ponentes que presiden alguna sesión del congreso: su nombre y el nombre
de la sesión o sesiones que presiden.
SELECT Ponente.Nombre, Se.Nombre
FROM Ponente JOIN Sesion Se ON Ponente.DNI = Se.DNI
ORDER BY Ponente.Nombre;

11. Mostrar todos ponentes del congreso y, si presentan ponencias, las ponencias que
presentan: su nombre y el título de la ponencia que presenta. En caso de no presentar
ninguna debe aparecer el texto ‘No presenta’, en lugar del título de la ponencia.

12. Mostrar los ponentes que no presentan ninguna ponencia en el congreso: dni, nombre
y empresa.

13. Mostrar el número total de sesiones que se van a realizar cada día en la sala BOSQUE,
ordenadas por fecha: día y número total.

14. Mostrar la media del precio de las salas, con dos decimales de precisión.

15. Mostrar cuantos ponentes del congreso hay de cada país, ordenados de mayor a
menor por número de ponentes: país y número total.

16. Mostrar los países que tienen más de 2 ponentes en el congreso, ordenados de mayor
a menor por número de ponentes: país y número total.

17. Si el congreso se retrasara 20 días, mostrar las nuevas fechas de cada sesión: día (en
formato dd-mmaaaa), número de sesión y nombre de sesión.

18. Si unimos las salas SALA1 y SALA2 ¿cuál sería su capacidad?

19. Mostrar los días en los que hay más de dos sesiones: día (en formato dd-mm-aaaa) y
número de sesiones en el día.

20. Mostrar las salas con capacidad menor de 40 y en las que se celebre alguna sesión:
nombre de la sala, capacidad y número total de sesiones que se celebran en ella.

21.

22. Mostrar el número de ponencias que se presentan por cada tema (nombre de sesión),
ordenadas alfabéticamente por nombre de sesión: nombre de sesión, número de
ponencias.

23. Suponiendo que el coste de alquiler de las salas es diario, independientemente del
número de sesiones, obtener el coste de alquiler del congreso por día: día (formato
dd-mm-aaaa), coste del día.

24. Mostrar los nombre de los ponentes que son de la misma empresa que el ponente que
ha presentado la ponencia titulada PROLOG. No mostrar el nombre de este ponente.

25. Mostrar todos los títulos de los eventos del congreso, ya sean sesiones o ponencias,
ordenados alfabéticamente. Al lado de cada título indicar si es una sesión o una
ponencia.

26. Mostrar los días y personas que exponen en salas de más de 30 personas de
capacidad: sala, día (en formato dd-mm-aaaa), nombre de ponente.

27. Mostrar el nombre de todos los ponentes que participan en el congreso y a su lado el
número de ponencias que presentan y el número de sesiones que presiden.

28. Mostrar los países que tienen más participantes que JAPON en el congreso.

29. Mostrar las salas y el precio por plaza de cada una. Suponemos que el precio por plaza
será la división entre el precio de alquiler y la capacidad de la sala. Expresar el
resultado sin decimales. Añadir una columna que se llame precio-menor, que muestre
un asterisco cuando el precio por plaza de una sala sea inferior al precio por plaza de la
sala BOSQUE.

30. Mostrar para cada sesión, el día que se celebra (formato dd-mm-aaaa), su número de
sesión, el título de la sesión, la sala en que se realiza, el precio y la capacidad de la sala,
el nombre de la persona que la preside y el número de ponencias que se presentan.

31. Mostrar todas las empresas que participan en el congreso y el número de ponentes y
de ponencias de cada una
