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
    VALUES (TG_TABLE_NAME, TG_OP, current_user, current_timestamp);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auditoria_trigger
AFTER INSERT OR UPDATE OR DELETE ON Disco
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
AFTER INSERT ON Tiene
FOR EACH ROW EXECUTE FUNCTION comprobar_lista_deseados();

ROLLBACK;

