DROP TABLE Personas2;
CREATE TABLE Personas2(
    Id          SERIAL          NOT NULL,
    Nombre      VARCHAR(100)    NOT NULL,
    Estado      SMALLINT        NOT NULL,
    PRIMARY KEY (Id, Estado)
) PARTITION BY LIST(Estado); --- LIST: Particionamos en función de los distintos valores que tiene el campo Estado

CREATE TABLE personas_en_estado_1       PARTITION OF personas2 FOR VALUES IN (1);
CREATE TABLE personas_en_estado_2       PARTITION OF personas2 FOR VALUES IN (2);
CREATE TABLE personas_en_estado_otros   PARTITION OF personas2 DEFAULT; -- El resto

INSERT INTO Personas2 (Nombre, Estado) VALUES ('Ivan', 1);
INSERT INTO Personas2 (Nombre, Estado) VALUES ('Lucas', 1);
INSERT INTO Personas2 (Nombre, Estado) VALUES ('Menchu', 1);
INSERT INTO Personas2 (Nombre, Estado) VALUES ('Felipe', 2);
INSERT INTO Personas2 (Nombre, Estado) VALUES ('Carmen', 2);
INSERT INTO Personas2 (Nombre, Estado) VALUES ('Rodrigo', 2);
INSERT INTO Personas2 (Nombre, Estado) VALUES ('Marcial', 3);


-- Dame todas las personas
select * FROM personas2;
-- Dame todas las personas y la tabla en la que se encuentran
select tableoid::regclass, * FROM personas2;
-- Dame las personas en estado 2
select * FROM personas_en_estado_2;

-- Dame la union de todas las tablas de pesonas
select * FROM personas_en_estado_1
UNION ALL
select * FROM personas_en_estado_2
UNION ALL
select * FROM personas_en_estado_otros;

-- Vamos a ver que hace por debajo:
EXPLAIN select * FROM personas2;
EXPLAIN select * FROM personas_en_estado_1
UNION ALL
select * FROM personas_en_estado_2
UNION ALL
select * FROM personas_en_estado_otros;


-- EJEMPLO 2

DROP TABLE Personas3;
CREATE TABLE Personas3(
    Id          SERIAL          NOT NULL,
    Nombre      VARCHAR(100)    NOT NULL,
    Edad        SMALLINT        NOT NULL,
    PRIMARY KEY (Id, Edad)
) PARTITION BY RANGE(Edad); --- RANGE: Rangos en función de la variable EDAD
                                                                                        -- Este no se incluye
CREATE TABLE Personas_jovenes       PARTITION OF personas3 FOR VALUES FROM (MINVALUE)   TO (20);
CREATE TABLE Personas_adultas       PARTITION OF personas3 FOR VALUES FROM (20)         TO (70);
CREATE TABLE personas_ancianas      PARTITION OF personas3 FOR VALUES FROM (70)         TO (MAXVALUE); -- El resto

INSERT INTO Personas3 (Nombre, Edad) VALUES ('Ivan', 10);
INSERT INTO Personas3 (Nombre, Edad) VALUES ('Lucas', 18);
INSERT INTO Personas3 (Nombre, Edad) VALUES ('Menchu', 20);
INSERT INTO Personas3 (Nombre, Edad) VALUES ('Felipe', 26);
INSERT INTO Personas3 (Nombre, Edad) VALUES ('Carmen', 52);
INSERT INTO Personas3 (Nombre, Edad) VALUES ('Rodrigo', 70);
INSERT INTO Personas3 (Nombre, Edad) VALUES ('Marcial', 83);



-- Dame todas las personas
select * FROM personas3;
-- Dame todas las personas y la tabla en la que se encuentran
select tableoid::regclass, * FROM personas3;
-- Dame las personas en estado 2
select * FROM Personas_jovenes;

-- Dame la union de todas las tablas de pesonas
select * FROM Personas_jovenes
UNION ALL
select * FROM Personas_adultas
UNION ALL
select * FROM Personas_ancianas;

-- Vamos a ver que hace por debajo:
EXPLAIN select * FROM personas3;
EXPLAIN select * FROM Personas_jovenes
UNION ALL
select * FROM Personas_adultas
UNION ALL
select * FROM Personas_ancianas;
