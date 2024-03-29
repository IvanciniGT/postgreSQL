CREATE OR REPLACE FUNCTION letra_dni(numero_dni int4)
RETURNS char AS $$
DECLARE
    letra_devolver char(1);
BEGIN
    SELECT LETRA INTO letra_devolver FROM LETRAS_DNI WHERE RESTO=MOD(numero_dni,23); 
    RETURN letra_devolver;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION validar_letra()
RETURNS trigger AS 
$$
BEGIN
    IF ( letra_dni(NEW.numero_dni) <> NEW.letra_dni ) THEN
        RAISE EXCEPTION 'Letra de control del DNI incorrecta';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Esta funcion, al ser una función que usamos en un trigger, recibe un dato llamado: 
-- - NEW: Es la fila que quiero insertar (INSERT) o los datos que quiero actualizar (UPDATE)
-- - OLD: Los datos anteriores que había en caso que esté haciendo un (UPDATE) o un (DELETE)
    
-- Trigger: EVENTOS: INSERT or UPDATE
--                                 AFTER. DELETE
CREATE TRIGGER validador_letra_dni BEFORE INSERT OR UPDATE ON Personas
FOR EACH ROW EXECUTE PROCEDURE validar_letra();

