-- TRIGGERS
CREATE TABLE IF NOT EXISTS auditoria (
    id SERIAL PRIMARY KEY,
    tabla_afectada VARCHAR(255),
    tipo_evento VARCHAR(50),
    usuario VARCHAR(255),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION auditoria_funcion()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (tabla_afectada, tipo_evento, usuario, fecha_hora)
    VALUES (TG_RELNAME, TG_OP, current_user, current_timestamp);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear triggers para cada tabla
CREATE TRIGGER auditoria_trigger_tiene
AFTER INSERT OR UPDATE OR DELETE ON base_discos.Tiene
FOR EACH ROW EXECUTE FUNCTION auditoria_funcion();

CREATE TRIGGER auditoria_trigger_desea
AFTER INSERT OR UPDATE OR DELETE ON base_discos.Desea
FOR EACH ROW EXECUTE FUNCTION auditoria_funcion();

CREATE TRIGGER auditoria_trigger_cancion
AFTER INSERT OR UPDATE OR DELETE ON base_discos.Cancion
FOR EACH ROW EXECUTE FUNCTION auditoria_funcion();

CREATE TRIGGER auditoria_trigger_disco
AFTER INSERT OR UPDATE OR DELETE ON base_discos.Disco
FOR EACH ROW EXECUTE FUNCTION auditoria_funcion();

CREATE TRIGGER auditoria_trigger_usuario
AFTER INSERT OR UPDATE OR DELETE ON base_discos.Usuario
FOR EACH ROW EXECUTE FUNCTION auditoria_funcion();

CREATE TRIGGER auditoria_trigger_genero
AFTER INSERT OR UPDATE OR DELETE ON base_discos.Generos
FOR EACH ROW EXECUTE FUNCTION auditoria_funcion();

CREATE TRIGGER auditoria_trigger_edicion
AFTER INSERT OR UPDATE OR DELETE ON base_discos.Edicion
FOR EACH ROW EXECUTE FUNCTION auditoria_funcion();

CREATE TRIGGER auditoria_trigger_grupo
AFTER INSERT OR UPDATE OR DELETE ON base_discos.Grupo
FOR EACH ROW EXECUTE FUNCTION auditoria_funcion();

CREATE OR REPLACE FUNCTION comprobar_lista_deseados()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM Desea
    WHERE usuario_id = NEW.usuario_id AND disco_id = NEW.disco_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_comprobar_lista_deseados
AFTER INSERT ON base_discos.Tiene
FOR EACH ROW EXECUTE FUNCTION comprobar_lista_deseados();

COMMIT;