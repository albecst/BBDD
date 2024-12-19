import psycopg2

def prueba_users(nombre_user, password):
    """
    prueba si los permisos de un usarios de han creado intentando acceder a varias tablas
    hace LIMIT 2 para no mostrar el contenido de todas la tablas y saturar de informacion irrelevante que sature la terminal
    """
    try:
        connstring = f'host=localhost port=5432 user={nombre_user} password={password} dbname=PL3_discos' 
        conn = psycopg2.connect(connstring) 
        cur = conn.cursor()

        query = "SELECT * FROM base_discos.Disco LIMIT 1"                                      
        cur.execute(query)                                                  
        for record in cur.fetchall():                                          
            print(record)
        #hasta aquí llega invitado

        query = "SELECT * FROM base_discos.Tiene LIMIT 1"                                      
        cur.execute(query)                                                  
        for record in cur.fetchall():                                          
            print(record)
        #hasta aquí llega cliente

        query = "SELECT * FROM base_discos.Usuario LIMIT 1"                                      
        cur.execute(query)                                                  
        for record in cur.fetchall():                                          
            print(record)
        #hasta aquí llega admin

        query = "CREATE TABLE IF NOT EXISTS base_discos.pruebas(nombre TEXT)"                                      
        cur.execute(query)
        print("tabla creada")
        #hasta aquí llega gestor

    except Exception as e:
        conn.rollback()
        print(f"Error: {e}")
    finally:
        conn.rollback() #como es una prueba no se guardan los cambios
        cur.close()
        conn.close()
#PRUEBAS
print("\nPrueba cliente")
prueba_users("cliente","cliente")

print("\nPrueba invitado")
prueba_users("invitado","invitado")

print("\nPrueba gestor")
prueba_users("gestor","gestor")

print("\nPrueba admin")
prueba_users("admin","admin")