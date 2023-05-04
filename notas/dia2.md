
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

# Tenemos varios tipos de INDICES EN POSTGRESQL

## Indices directos BTREE

CREATE INDEX importe_idx ON cursos (importe);  
CREATE INDEX importe_idx ON cursos (importe) TABLESPACE <espacio>;  

CREATE INDEX importe_idx ON cursos (importe) WITH (fillfactor = 70)

CREATE INDEX curso_titulo_idx ON cursos (titulo);  
CREATE INDEX curso_titulo_lower_idx ON cursos (lower(titulo));  

## Indices GIN 

CREATE INDEX curso_titulo_invertido_idx ON cursos USING GIN(to_tsvector('spanish', titulo));  

## Indices de tipo HASH

CREATE INDEX curso_titulo_hash_idx ON cursos USING HASH(titulo);  
SOLO PUEDO HACER: = IGUAL      != <> DISTINTO
A cambio, Son muy fáciles de mantener y mucho más pequeños


# Regeneracion de un índice

REINDEX INDEX curso_titulo_lower_idx;

# Operaciones típicas de mnto de la BBDD

REINDEX
ANALYZE <TABLA> [(COLUMNA 1, COLUMNA 2)]
VACUUM <TABLA>

BBDD producción -> ETL -> Datawarehouse
Tengo los datos de los ultimos 3/4 años 
El resto me los llevo a un datawarehouse

LETRA_DNI -> 1/23%
Columna DNIs                \
Columna Nombre de Persona   / 200k datos -> Tengo unas estadísticas

                            + 20k datos nuevos -> He de regenerar estadísticas? posiblemente no.
FECHA de carga

# Particionado de tablas

Para que sirve? 
- Diferentes operaciones
- Acceso más rápido a los datos
- Facilitar el mnto de los datos

Para plantearme un particionado lo primero que necesito es una tabla GRANDE !
Tener un criterio claro de particionado... es cierto en muchos casos... pero no siempre.

Al particionar una tabla en postgres, lo que en realidad estamos haciendo es crear varias tablas a las que acceder conjuntamente con un nombre o no!

# EJEMPLOS DE USO:

Tengo una BBDD con expedientes de ???
Partición 1: Expedientes abiertos
Partición 2: Expedientes cerrados

Tengo una tabla con muchos datos vivos... pero tengo muchos !
Me puede interesar repartir esos datos en 3 tablas... sin criterio alguno... de forma aleatoria, ya que?
- Puedo tener 3 espacios de almacenamiento diferentes para esas tablas... Trabajao sobre las 3 tablas a la vez
- Mantenimiento: VACUUM

## OJO

Hay un tema a tener en cuenta.
El campo ID estando definido como clave UNICA y PRIMARIA.... puede repetirse entre las particiones.

TABLA EXPEDIENTES: Id, Nombre, Estado
                    1  a        abierto
                    2  b        abierto
                    3  c        cerrado

expedientes (expedientes_abiertos UNION ALL expedientes_cerrados)
    expedientes_abiertos
                    Id, Nombre, Estado
                    1  a        abierto
                    2  b        abierto
    expedientes_cerrados
                    Id, Nombre, Estado
                    3  c        cerrado                    
                    1  d        cerrado ** ESTO ES POSIBLE EN TABLAS PARTICIONADAS. Peligro !

### Limitación: Factor a tener en cuenta cuando trabajamos con tablas particionadas:
La PK debe contener el campo de particionado

## Como lo implementamos:
 
### Paso1: Defino la tabla GENERAL que quiero particionar
En ella defino:
- Las columnas
- Indices que quiero que apliquen a las diferentes particiones
Debo dar un "criterio"(campo) de particionado... hay varios que podemos usar en PG
                    Expedientes.estado

### Paso2: Defino cada una de las tablas de particionado
En ellas doy el criterio de los datos que entran en esa tabla de particionado concreta:
Expedientes.estado = ABIERTOS
Además, puedo definir sus propios INDICES!