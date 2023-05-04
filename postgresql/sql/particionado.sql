DROP TABLE Personas2;
CREATE TABLE Personas2(
    Id          SERIAL          NOT NULL,
    Nombre      VARCHAR(100)    NOT NULL,
    Estado      SMALLINT        NOT NULL
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
