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

def print_options():
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
                # insertar disco
                #continue
                print("nada")

            elif opcion == '2':
                cur = conn.cursor() # instacia un cursor    
                query = 'SELECT Titulo_Disco FROM base_discos.Disco WHERE (SELECT COUNT(*) FROM base_discos.Cancion WHERE base_discos.Disco.Ano_Publicacion = base_discos.Cancion.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco) > 5'
                cur.execute(query)                                                  # ejecuta la consulta
                for record in cur.fetchall():                                       # fetchall devuelve todas las filas de la consulta
                    print(record)                                                   # imprime las filas
                cur.close() 

            elif opcion == '3':
                cur = conn.cursor() 
                query = "SELECT Titulo_Disco, Pais_Edicion, Ano_Edicion FROM base_discos.Tiene JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario WHERE base_discos.Usuario.Nombre = 'Juan García Gómez' AND base_discos.Tiene.Formato_Edicion = 'Vinyl'"                                    
                cur.execute(query) 
                for record in cur.fetchall():                                           
                    print(record) 
                cur.close()

            elif opcion == '4':
                cur = conn.cursor()                                                    
                query = 'WITH DuracionDiscos (Duracion,Titulo_Disco) AS (SELECT SUM(base_discos.Cancion.Duracion), base_discos.Disco.Titulo_Disco FROM base_discos.Cancion JOIN base_discos.Disco ON base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco GROUP BY base_discos.Disco.Titulo_Disco)SELECT Titulo_Disco, Duracion FROM DuracionDiscos WHERE Duracion = (SELECT MAX(Duracion) FROM DuracionDiscos)' 
                cur.execute(query)                                                    
                for record in cur.fetchall():                                           
                    print(record)                                                      
                cur.close()                                                            

            elif opcion == '5':
                cur = conn.cursor()                                                  
                query = "SELECT Nombre_Grupo FROM base_discos.Disco JOIN base_discos.Desea ON base_discos.Disco.Ano_Publicacion = base_discos.Desea.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Desea.Titulo_Disco JOIN base_discos.Usuario ON base_discos.Desea.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario WHERE base_discos.Usuario.Nombre = 'Juan García Gómez'"  
                cur.execute(query)                                                  
                for record in cur.fetchall():                                          
                    print(record)                                                       
                cur.close()                                                            

            elif opcion == '6':
                cur = conn.cursor()                                                    
                query = 'SELECT base_discos.Disco.Titulo_Disco, base_discos.Disco.Ano_Publicacion, base_discos.Edicion.Ano_Edicion FROM base_discos.Disco JOIN base_discos.Edicion ON base_discos.Disco.Titulo_Disco = base_discos.Edicion.Titulo_Disco  WHERE base_discos.Disco.Ano_Publicacion >= 1970 AND base_discos.Disco.Ano_Publicacion <= 1972 ORDER BY base_discos.Disco.Ano_Publicacion'                                        
                cur.execute(query)                                                     
                for record in cur.fetchall():                                           
                    print(record)                                                     
                cur.close()                                                            

            elif opcion == '7':
                cur = conn.cursor()                                                  
                query = "SELECT DISTINCT base_discos.Grupo.Nombre FROM base_discos.Grupo JOIN base_discos.Disco ON base_discos.Grupo.Nombre = base_discos.Disco.Nombre_Grupo JOIN base_discos.Generos ON base_discos.Disco.Titulo_Disco = base_discos.Generos.Titulo_Disco WHERE base_discos.Generos.Genero LIKE '%Electronic%'"                                    
                cur.execute(query)                                                      
                for record in cur.fetchall():                                           
                    print(record)                                                     
                cur.close()              

            elif opcion == '8':
                cur = conn.cursor()                                                     
                query = 'SELECT base_discos.Disco.Titulo_Disco, SUM(base_discos.Cancion.Duracion) FROM base_discos.Disco JOIN base_discos.Cancion ON base_discos.Disco.Titulo_Disco = base_discos.Cancion.Titulo_Disco WHERE base_discos.Disco.Ano_Publicacion < 2000 GROUP BY base_discos.Disco.Titulo_Disco'                                        
                cur.execute(query)                                                     
                for record in cur.fetchall():                                          
                    print(record)                                                       
                cur.close()                                                            

            elif opcion == '9':
                cur = conn.cursor()                                                    
                query = "WITH Deseados_Lorena(Formato, Ano_Edicion, Pais, Ano_Publicacion_Disco, Titulo_Disco ) AS (SELECT Formato, Ano_Edicion, Pais, base_discos.Edicion.Ano_Publicacion_Disco, base_discos.Edicion.Titulo_Disco FROM base_discos.Desea JOIN base_discos.Usuario ON base_discos.Desea.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario JOIN base_discos.Edicion ON base_discos.Desea.Ano_Publicacion_Disco = base_discos.Edicion.Ano_Publicacion_Disco AND base_discos.Desea.Titulo_Disco = base_discos.Edicion.Titulo_Disco WHERE base_discos.Desea.Nombre_Usuario = 'Lorena Sáez Pérez') SELECT dl.Formato, dl.Ano_Edicion, Pais, dl.Ano_Publicacion_Disco, dl.Titulo_Disco FROM base_discos.Tiene JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario JOIN Deseados_Lorena dl ON dl.Ano_Publicacion_Disco = base_discos.Tiene.Ano_Publicacion_Disco AND dl.Titulo_Disco = base_discos.Tiene.Titulo_Disco WHERE base_discos.Tiene.Nombre_Usuario = 'Juan García Gómez'"
                cur.execute(query)                                                     
                for record in cur.fetchall():                                          
                    print(record)                                                      
                cur.close()                                                            

            elif opcion == '10':
                cur = conn.cursor()                                                   
                query = "SELECT Formato_Edicion, Ano_Edicion, Pais_Edicion, Ano_Publicacion_Disco, Titulo_Disco FROM base_discos.Tiene JOIN base_discos.Usuario ON base_discos.Tiene.Nombre_Usuario = base_discos.Usuario.Nombre_Usuario WHERE base_discos.Usuario.Nombre LIKE '%Gómez García' AND (Estado = 'NM' OR Estado = 'M')" 
                cur.execute(query)                                                      
                for record in cur.fetchall():                                           
                    print(record)                                                       
                cur.close()                                                               

            elif opcion == '11':
                cur = conn.cursor()                                                   
                query = "SELECT Nombre_Usuario, COUNT(*), MIN(Ano_Edicion), MAX(Ano_Edicion), AVG(Ano_Edicion) FROM base_discos.Tiene GROUP BY Nombre_Usuario"                                     
                cur.execute(query)                                                      
                for record in cur.fetchall():                                           
                    print(record)                                                   
                cur.close()                                                   

            elif opcion == '12':
                cur = conn.cursor()                                                    
                query = 'SELECT Nombre_Grupo FROM base_discos.Disco JOIN base_discos.Edicion ON base_discos.Disco.Ano_Publicacion = base_discos.Edicion.Ano_Publicacion_Disco AND base_discos.Disco.Titulo_Disco = base_discos.Edicion.Titulo_Disco GROUP BY Nombre_Grupo HAVING COUNT(*) > 5'     
                cur.execute(query)                                                     
                for record in cur.fetchall():                                          
                    print(record)                                                      
                cur.close()                                                            

            elif opcion == '13':
                cur = conn.cursor()                                                  
                query = "SELECT Nombre_Usuario FROM base_discos.Tiene GROUP BY Nombre_Usuario HAVING COUNT(*) = (SELECT MAX(NumDiscos) FROM (SELECT COUNT(*) AS NumDiscos FROM base_discos.Tiene GROUP BY Nombre_Usuario) AS NumDiscos)"                                      
                cur.execute(query)                                                  
                for record in cur.fetchall():                                          
                    print(record)                                                       
                cur.close()                                                              
            
            elif opcion == '-1':
                conn.close() #cierra la conexion 
                print("...cerrando...")
                break
            
            else:
                print("Opción no válida")
             
        except (psycopg2.errors.InsufficientPrivilege, psycopg2.errors.InFailedSqlTransaction):
            print("El usuario actual no puede realizar esta consulta")
        except KeyboardInterrupt:
            print("Program interrupted by user.")
            conn.close()
            break
        



if __name__ == "__main__":                                                      # Es el modula principal?
    if '--test' in sys.argv:                                                    # chequea el argumento cmdline buscando el modo test
        import doctest                                                          # importa la libreria doctest
        doctest.testmod()                                                       # corre los tests
    else:                                                                       # else
        main()                                                                  # ejecuta el programa principal