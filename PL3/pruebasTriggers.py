import psycopg2

def prueba_triggers(nombre_usuario,titulo_disco,formato_edicion,ano_edicion,pais_edicion,estado,nombre_grupo,ano_publicacion,url_portada=""):
    """
    Prueba el funcionamiento de los triggers, insertando disco en Desea y en las demás tablas que corresponda 
    y muestra la tabla auditoría para ver los cambios que se han hecho en la tablas de la BBDD.
    Hace rollback ya que como es una prueba no queremos que se guarden los cambios.
    """
    try:
        connstring = f'host=localhost port=5432 user=cliente password=cliente dbname=PL3_discos' 
        conn = psycopg2.connect(connstring) 
        cur = conn.cursor()
            
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
            
        
        print("Disco, grupo, canciones y edición insertados correctamente.")
        #mostrar tabla auditoria para comprobar los cambios
        query = "SELECT * FROM auditoria"                                      
        cur.execute(query)                                                  
        for record in cur.fetchall():                                          
            print(record)  
    except Exception as e:
        conn.rollback()
        print(f"Error al insertar el disco, grupo, canciones y edición: {e}")
    finally:
        conn.rollback() #como es una prueba no se guardan los cambios
        cur.close()
        conn.close()

#PRUEBAS (probamos las distintas posibilidades que pueden ocurrir):
print("\ndisco que ya existe en Disco, en Edicion y en Desea: ")
prueba_triggers("martamoreno","Ivy","Vinyl","1989","UK","M","Primal Scream","1991")

print("\ndisco que ya existe en Disco y en Desea: ")
#nos inventamos una edicion de un disco que ya esta
prueba_triggers("javierfernández","Heterogenial","Vinyl","2000","Spain","M","Nikola Parov","1994") 

print("\ndisco que solo existe en Disco y en Edicion: ")
prueba_triggers("javierfernández","The Receiver","Vinyl","1980","US","M","Wagon Christ","1980")

print("\ndisco que solo existe en Disco: ")
prueba_triggers("martamoreno","Pesadillas","CD","2018","Greece","M","Akheron","1992")

print("\nusuario que no existe: ")
prueba_triggers("pepe","Pesadillas","CD","2018","Greece","M","Akheron","1992")

print("\nEl disco ya está en tiene para el usuario: ")
prueba_triggers("juangomez","Lavatory","CD","2012","Russia","VG+","Wombbath","2012")

print("\ndisco que no existe en la bbdd: ")
prueba_triggers("martamoreno","inventado","CD","2024","Latvia","M","anonimo","2015")

print("\ndisco que no existe en la bbdd pero el grupo sí: ")
prueba_triggers("martamoreno","inventado","CD","2024","Latvia","M","Bee Gees","2015")