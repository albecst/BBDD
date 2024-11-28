import sys
import psycopg2
import pytest

class portException(Exception): pass

def ask_port(msg):
    """
        ask for a valid TCP port
        ask_port :: String -> IO Integer | Exception
    """
    try:                                                                        # try
        answer  = input(msg)                                                    # pide el puerto
        port    = int(answer)                                                   # convierte a entero
        if (port < 1024) or (port > 65535):                                     # si el puerto no es valido
            raise ValueError                                                    # lanza una excepción
        else:
            return port
    except ValueError:     
        raise portException                                                     # raise portException
    #finally:                                                                    # finally
    #    return port                                                             # return port

def ask_conn_parameters():
    """
        ask_conn_parameters:: () -> IO String
        pide los parámetros de conexión
        TODO: cada estudiante debe introducir los valores para su base de datos
    """
    host = 'localhost'                                                          # 
    port = ask_port('TCP port number: ')                                        # pide un puerto TCP
    user = 'prueba'                                                                   # TODO
    password = 'Prueba'                                                               # TODO
    database = 'PL3_discos'                                                               # TODO
    return (host, port, user,
             password, database)

def print_options():
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
    print("13. Lista el usuario que más discos, contando todas sus ediciones tiene en la base de datos")


def main():
    """
        main :: () -> IO None
    """
    opcion = ''
    try:
        (host, port, user, password, database) = ask_conn_parameters()          #
        connstring = f'host={host} port={port} user={user} password={password} dbname={database}' 
        conn    = psycopg2.connect(connstring)                                  #
                                                                               
        while opcion != -1:
            print_options()
            opcion = input("Introduce una opción (-1 para salir):")
            
            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor
            
            if opcion == '1s':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor

            if opcion == '1':
                cur     = conn.cursor()                                                 # instacia un cursor    
                query   = 'SELECT * FROM Disco'                                        # prepara una consulta
                cur.execute(query)                                                      # ejecuta la consulta
                for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
                    print(record)                                                       # imprime las filas
                cur.close                                                               # cierra el cursor
            
            
        conn.close                                                              # cierra la conexion
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        print("Program finished")

#def prueba_conexion():


if __name__ == "__main__":                                                      # Es el modula principal?
    if '--test' in sys.argv:                                                    # chequea el argumento cmdline buscando el modo test
        import doctest                                                          # importa la libreria doctest
        doctest.testmod()                                                       # corre los tests
    else:                                                                       # else
        main()                                                                  # ejecuta el programa principal
