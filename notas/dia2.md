
# Instalacion Adminer



    ---------------- Red Inetum
            v
            10.228.130.221
            v
    ---------------- Red porcelanosa
    |
    128.1.99.99 : 5432 POSTGRESQL
    |
    Host PostgreSQL 0.0.0.0:8080 -> 10.88.0.2:8080
    |
    |
    |- 10.88.0.2 - Contenedor de Adminer : 8080
    |
    | Red virtual de podman

# Tipos de datos en PostgreSQL

## Númericos

smallint, int2              2 bytes 
integer, int, int4          4 bytes
bigint, int8                8 bytes
numeric(digitos, de esos dígitos cuantos decimales)        Ancho variable

## textos

char(n), character(n)      Dependiendo del ancho del texto (n) y del collate
varchar(n)
text                        Equivalente a un CLOB de Oracle

## Logicos:

Boolean, bool

## Fechas

timestamp with[out] time zone               8 bytes
date                                        4 bytes
time with[out] time zone                    8 bytes

## Binarios

bytea                      Equivalente a un BLOB de Oracle

## Serial < Estos campos me permiten trabajar con autogenerados (IDs)

smallserial     int2
serial          int4
bigserial       int8

# EL PADDING DE 8 bytes de PostgreSQL

smallint    SS
int         IIII
bigint      BBBBBBBB

Postgres debe asegurarse que un campo que ocupe 8, empiece en un byte multiplo de 8

FILA    bigint bigint smallint int
                |        |        |
        BBBBBBBB BBBBBBBB SSIIII

        8+8+6 +24 = 46

FILA    smallint bigint int bigint
                |        |        |
        SS       BBBBBBBB IIII     BBBBBBBB
        8x4 = 32 + 24 por defecto = 56
