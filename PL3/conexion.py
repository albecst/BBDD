import sys
import psycopg2
import pytest

class portException(Exception): pass

def ask_port(msg):
    """
        ask for a valid TCP port
        ask_port :: String -> IO Integer | Exception
    """
    try:
        answer  = input(msg)                                                    # pide el puerto
        port    = int(answer)                                                   # convierte a entero
        if (port < 1024) or (port > 65535):                                     # si el puerto no es valido
            raise ValueError                                                    # lanza una excepción
        else:
            return port
    except ValueError:     
        raise portException                                                     # raise portException

def ask_conn_parameters():
    """
        ask_conn_parameters:: () -> IO String
        pide los parámetros de conexión
        TODO: cada estudiante debe introducir los valores para su base de datos
    """
    host = 'localhost'                                                          # 
    port = ask_port('TCP port number: ')                                        # pide un puerto TCP
    user = input("Introduce tu usuario: ")                                      # pide el usuario
    password = input("Contraseña: ")                                            # pide la contraseña
    database = 'PL3_discos'                                                     # nombre de la base de datos
    return (host, port, user, password, database)

def uebaint_options():
    print()
    print("1. Insertar disco")
    print("2. Mostrar los discos que tengan más de 5 canciones. Construir la expresión equivalente en álgebra relacional")
    print("3. Mostrar los vinilos que tiene el usuario Juan García Gómez junto con el título del disco, y el país y año de edición del mismo")
    print("4. Disco con mayor duración de la colección. Construir la expresión equivalente en álgebra relacional")
    print("5. De los discos que tiene en su lista de deseos el usuario Juan García Gómez, indicar el nombre de los grupos musicales que los interpretan")
    print("6. Mostrar los discos publicados entre 1970 y 1972 junto con sus ediciones ordenados por el año de publicación.")
    print("7. Listar el nombre de todos los grupos que han publicado discos del género ‘Electronic’. Construir la expresión equivalente en álgebra relacional")
    print("8. Lista de discos con la duración total del mismo, editados antes del año 2000")
    print("9. Lista de ediciones de discos deseados por el usuario Lorena Sáez Pérez que tiene el usuario Juan García Gómez")
    print("10. Lista todas las ediciones de los discos que tiene el usuario Gómez García en un estado NM o M.")
    print("11. Listar todos los usuarios junto al número de ediciones que tiene de todos los discos junto al año de lanzamiento de su disco más antiguo, el año de lanzamiento de su disco más nuevo, y el año medio de todos sus discos de su colección")
    print("12. Listar el nombre de los grupos que tienen más de 5 ediciones de sus discos en la base de datos")
    print("13. Lista el usuario que más discos, contando todas sus ediciones tiene en la base de datos\n")
    print()

def insertar_disco_y_canciones(conn):
    """
    Inserta un nuevo disco, su grupo y las canciones asociadas en la base de datos.
    """
    try:
        cur = conn.cursor()
                    
        # Solicitar detalles del disco
        nombre_usuario = input("Introduce el nombre del usuario: ")
        titulo_disco = input("Introduce el título del disco: ")
        formato_edicion = input("Introduce el formato de la edición: ")
        ano_edicion = int(input("Introduce el año de la edición: "))
        pais_edicion = input("Introduce el país de la edición: ")
        estado = input("Introduce el estado de la edición: ")
        nombre_grupo = input("Introduce el nombre del grupo: ")
        ano_publicacion = int(input("Introduce el año de publicación: "))
        url_portada = input("Introduce la URL de la portada (opcional): ")
        
        # Verificar si el disco ya existe en Tiene
        cur.execute("""
            SELECT COUNT(*) FROM base_discos.Tiene 
            WHERE Titulo_Disco = %s AND Ano_Publicacion_Disco = %s AND Nombre_Usuario = %s
        """, (titulo_disco, ano_publicacion, nombre_usuario))
        if cur.fetchone()[0] != 0:
            print("El disco ya existe en la colección del usuario.")
            return
        
        # Verificar si el disco ya existe en Disco
        cur.execute("SELECT COUNT(*) FROM base_discos.Disco WHERE Titulo_Disco = %s AND Ano_Publicacion = %s", (titulo_disco, ano_publicacion))
        if cur.fetchone()[0] == 0:
            # Verificar si el grupo ya existe
            cur.execute("SELECT COUNT(*) FROM base_discos.Grupo WHERE Nombre = %s", (nombre_grupo,))
            if cur.fetchone()[0] == 0:
                # Insertar el grupo si no existe
                url_grupo = input("Introduce la URL del grupo: ")
                cur.execute("INSERT INTO base_discos.Grupo (Nombre, URL_Grupo) VALUES (%s, %s)", (nombre_grupo, url_grupo))
            
            # Insertar el disco
            cur.execute("""
                INSERT INTO base_discos.Disco (Ano_Publicacion, Titulo_Disco, Url_Portada, Nombre_Grupo)
                VALUES (%s, %s, %s, %s)
            """, (ano_publicacion, titulo_disco, url_portada, nombre_grupo))
            
            # Solicitar detalles de las canciones
            while True:
                titulo_cancion = input("Introduce el título de la canción (o 'fin' para terminar): ")
                if titulo_cancion.lower() == 'fin':
                    break
                duracion = input("Introduce la duración de la canción (formato HH:MM:SS): ")
                cur.execute("""
                    INSERT INTO base_discos.Cancion (Titulo_Cancion, Duracion, Titulo_Disco, Ano_Publicacion_Disco)
                    VALUES (%s, %s, %s, %s)
                """, (titulo_cancion, duracion, titulo_disco, ano_publicacion))
        
        #Insertar en la tabla edicion si no esta ya
        cur.execute("SELECT COUNT(*) FROM base_discos.Edicion WHERE Formato = %s AND Ano_Edicion = %s AND Pais = %s AND Ano_Publicacion_Disco = %s AND Titulo_Disco = %s" , (formato_edicion, ano_edicion, pais_edicion, ano_publicacion, titulo_disco))
        if cur.fetchone()[0] == 0:
            # la edicion no existe
            cur.execute("""
                        INSERT INTO base_discos.Edicion (Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco) 
                        VALUES (%s, %s, %s, %s, %s)
                        """, (formato_edicion, ano_edicion, pais_edicion, ano_publicacion, titulo_disco))

        # Insertar en la tabla Tiene
        cur.execute("""
            INSERT INTO base_discos.Tiene (Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco, Nombre_Usuario, Estado)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (formato_edicion, ano_edicion, pais_edicion, ano_publicacion, titulo_disco, nombre_usuario, estado))
        
        # Confirmar los cambios
        conn.commit()
        print("Disco, grupo, canciones y edición insertados correctamente.")
    except Exception as e:
        conn.rollback()
        print(f"Error al insertar el disco, grupo, canciones y edición: {e}")
    finally:
        cur.close()

def consulta(numero,conn):
    consultas=['SELECT Titulo_Disco FROM base_discos.Disco WHERE (SELECT COUNT(*) FROM base_discos.Cancion WHERE base_discos.Disco.Ano_Publicacion = base_discos.Cancion.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco) > 5',
               "SELECT Titulo_Disco, Pais_Edicion, Ano_Edicion FROM base_discos.Tiene JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario WHERE base_discos.Usuario.Nombre = 'Juan García Gómez' AND base_discos.Tiene.Formato_Edicion = 'Vinyl'",
               'WITH DuracionDiscos (Duracion,Titulo_Disco) AS (SELECT SUM(base_discos.Cancion.Duracion), base_discos.Disco.Titulo_Disco FROM base_discos.Cancion JOIN base_discos.Disco ON base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco GROUP BY base_discos.Disco.Titulo_Disco)SELECT Titulo_Disco, Duracion FROM DuracionDiscos WHERE Duracion = (SELECT MAX(Duracion) FROM DuracionDiscos)',
               "SELECT Nombre_Grupo FROM base_discos.Disco JOIN base_discos.Desea ON base_discos.Disco.Ano_Publicacion = base_discos.Desea.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Desea.Titulo_Disco JOIN base_discos.Usuario ON base_discos.Desea.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario WHERE base_discos.Usuario.Nombre = 'Juan García Gómez'",
               'SELECT base_discos.Disco.Titulo_Disco, base_discos.Disco.Ano_Publicacion, base_discos.Edicion.Ano_Edicion FROM base_discos.Disco JOIN base_discos.Edicion ON base_discos.Disco.Titulo_Disco = base_discos.Edicion.Titulo_Disco  WHERE base_discos.Disco.Ano_Publicacion >= 1970 AND base_discos.Disco.Ano_Publicacion <= 1972 ORDER BY base_discos.Disco.Ano_Publicacion',
               "SELECT DISTINCT base_discos.Grupo.Nombre FROM base_discos.Grupo JOIN base_discos.Disco ON base_discos.Grupo.Nombre = base_discos.Disco.Nombre_Grupo JOIN base_discos.Generos ON base_discos.Disco.Titulo_Disco = base_discos.Generos.Titulo_Disco WHERE base_discos.Generos.Genero LIKE '%Electronic%'",
               'SELECT base_discos.Disco.Titulo_Disco, SUM(base_discos.Cancion.Duracion) FROM base_discos.Disco JOIN base_discos.Cancion ON base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco WHERE base_discos.Disco.Ano_Publicacion < 2000 GROUP BY base_discos.Disco.Titulo_Disco',
               "WITH Deseados_Lorena(Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco ) AS (SELECT Formato, Ano_Edicion, Pais, base_discos.Edicion.Ano_Publicacion_Disco, base_discos.Edicion.Titulo_Disco FROM base_discos.Desea JOIN base_discos.Usuario ON base_discos.Desea.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario JOIN base_discos.Edicion ON base_discos.Desea.Ano_Publicacion_Disco = base_discos.Edicion.Ano_Publicacion_Disco AND base_discos.Desea.Titulo_Disco = base_discos.Edicion.Titulo_Disco WHERE base_discos.Desea.Nombre_Usuario = 'Lorena Sáez Pérez') SELECT dl.Formato, dl.Ano_Edicion, Pais, dl.Ano_Publicacion_Disco, dl.Titulo_Disco FROM base_discos.Tiene JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario JOIN Deseados_Lorena dl ON dl.Ano_Publicacion_Disco = base_discos.Tiene.Ano_Publicacion_Disco AND dl.Titulo_Disco = base_discos.Tiene.Titulo_Disco WHERE base_discos.Tiene.Nombre_Usuario = 'Juan García Gómez'",
               "SELECT Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco FROM base_discos.Tiene JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario WHERE base_discos.Usuario.Nombre LIKE '%Gómez García' AND (Estado = 'NM' OR Estado = 'M')",
                "SELECT Nombre_Usuario, COUNT(*), MIN(Ano_Edicion), MAX(Ano_Edicion), AVG(Ano_Edicion) FROM base_discos.Tiene GROUP BY Nombre_Usuario",
                'SELECT Nombre_Grupo FROM base_discos.Disco JOIN base_discos.Edicion ON base_discos.Disco.Ano_Publicacion = base_discos.Edicion.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Edicion.Titulo_Disco GROUP BY Nombre_Grupo HAVING COUNT(*) > 5',
                "SELECT Nombre_Usuario FROM base_discos.Tiene GROUP BY Nombre_Usuario HAVING COUNT(*) = (SELECT MAX(NumDiscos) FROM (SELECT COUNT(*) AS NumDiscos FROM base_discos.Tiene GROUP BY Nombre_Usuario) AS NumDiscos)"]
    cur = conn.cursor()
    query = consultas[numero-2] 
    cur.execute(query)
    for record in cur.fetchall():                                           
        print(record) 
    cur.close()
                        
def main():
    """
        main :: () -> IO None
    """
    opcion = ''
    conn = None
    while conn is None:
        try:
            (host, port, user, password, database) = ask_conn_parameters()          
            connstring = f'host={host} port={port} user={user} password={password} dbname={database}' 
            conn = psycopg2.connect(connstring) 
            print("¡Bienvenido!")                                 
        except portException:
            print("The port is not valid!")
        except (psycopg2.OperationalError, UnicodeDecodeError) :
            print("Usuario o contraseña incorrectos")
        except KeyboardInterrupt:
            print("Program interrupted by user.")
            return
        finally:
            if conn is None:
                print("Inténtalo de nuevo.")
    
    while opcion != '-1':
        try:
            print_options()
            opcion = input("Introduce una opción (-1 para salir):")
            
            if opcion == '1':
                if user=="invitado":
                    print("El invitado no puede insertar ningun dato a la base de datos")
                else: insertar_disco_y_canciones(conn)
    
            elif opcion == '2':
                consulta(2,conn)

            elif opcion == '3':
                consulta(3,conn)

            elif opcion == '4':
                consulta(4,conn)                                                            

            elif opcion == '5':
                consulta(5,conn)                                                           

            elif opcion == '6':
                consulta(6,conn)                                                          

            elif opcion == '7':
                consulta(7,conn)             

            elif opcion == '8':
                consulta(8,conn)                                                           

            elif opcion == '9':
                consulta(9,conn)                                                           

            elif opcion == '10':
                consulta(10,conn)                                                               

            elif opcion == '11':
                consulta(11,conn)                                                 

            elif opcion == '12':
                consulta(12,conn)                                                           

            elif opcion == '13':
                consulta(13,conn)                                                             
            
            elif opcion == '-1':
                conn.close() #cierra la conexion 
                print("...cerrando...")
                break
            
            else:
                print("Opción no válida")
             
        except (psycopg2.errors.InsufficientPrivilege, psycopg2.errors.InFailedSqlTransaction):
            print("El usuario actual no puede realizar esta consulta")
            if conn: conn.rollback() #si se realiza consulta fallida, se hace rollback para que se puedan seguir realizando más consultas
            #recupera la conexion del estado fallido
        except KeyboardInterrupt:
            print("Program interrupted by user.")
            conn.close()
            break
        



if __name__ == "__main__":                                                     
    if '--test' in sys.argv:                                                 
        import pruebasTriggers as pt, pruebasUsers as pu 
        print("Probando triggers: ")
        pt.probar()
        print("Probando users: ")
        pu.probar()
    else:                                                                     
        main()                                                                  