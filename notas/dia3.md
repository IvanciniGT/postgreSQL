
# Configuración de memoria

## Que afecta a la conf?

- Memoria total
- Tamaño de BBDD
- Tipo de queries
  - Tamaño de las respuestas
  - Número de ordenaciones
  - Joins
- Número de conexiones

## shared_buffers

Parametro más importante de Configuración.

Es lo que postgreSQL usa para cachear datos.
La regla general es 25% de la disponible.
Me puede interesar subirlo.
    > Tamaño de BBDD

## work_mem

Memoria que usamos para procesar queries (ordenaciones, merge)
    > Tipo de queries
    - Tamaño de las respuestas
    - Número de ordenaciones
    - Joins
    > Número de conexiones

## maintenance_work_mem (10%)

Memoria que usa la propia BBDD para operaciones de mantenimiento:
- Creación y refresco de indices, vacuum, regeneración de estadísticas

## effective_cache_size (70%)

No es un dato real de memoria.
Es una estimación de la memoria total que hay en el Host
que puede usarse para caches -> Incluyendo la que usa el propio SO

Esto se usa por el planificador de consultas.

# Mantenimiento de la BBDD

Es necesario ir haciendo algunas operaciones a la BBDD en producción para mantenerla a punto.
Algunas de ellas la propia BBDD (PG) las hace por si misma... el problema es cuando las hace.

## Regeneración de estadísticas de las tablas

Esto es importante para la eficiente ejecución de las queries (más bien para que el planificador tome decisiones más acertadas).

Este tema es importante hacerlo:
- Cuando haya cargas de datos que cambien significativamente las estadísticas:
  - Carga masiva                                                    <- Detrás de una carga masiva, también debo hacerlo
  - Por los insert/updates que se vayan haciendo en el día a día    <- De vez en cuando me planteo regenerar estadísticas
- De vez en cuando, me interesa una regeneración total (MUCHO TIEMPO)

Eso si: Para las columnas que realmente sufran un cambio.

-- Regenerar solo ciertas columnas
ANALYZE <TABLA> (<COLUMNAS SEPARADAS POR COMAS>);
    - Fechas
    - Estados de TAREAS/EXPEDIENTES....

-- Regenerar todas las estadisticas de la tabla.
ANALYZE <TABLA>;

-- Regenerar todas las estadísticas
ANALYZE;

## Compactado de los ficheros de datos de las tablas
### Tablas más pequeñas, menos espacio en HDD
### Impacto en rendimiento en lectura

Esto bloquea la tabla para su uso. Más que dejar a postgres decidir cuando hacer esto, me interesa adelantarme y hacerlo yo.

-- Empaqueta TODAS LAS TABLAS de la BBDD
VACUUM;

-- Empaquetar una TABLA
VACUUM <TABLA>;

## Regeneración de los indices

1º Tener muy claro que indices se usan y cuales no.
2º Los indices (algunos) se degradan mucho (FILLFACTOR)
3º Calcular la periodicidad para regerar los indices 

REINDEX TABLE <tabla>;
REINDEX INDEX <indice>;

### Estas operaciones de mnto muchas veces las empaquetamos... y obtenemos mejor rendimiento.

REINDEX VACUUM ANALYZE <tabla>;
VACUUM ANALYZE <tabla>;

# Backup y Restore

El tener replicación no me quita de hacer backups.

Debo definir una política muy clara de backup... según los criterios que quiera conseguir.

                                                                    Fecha más moderna a la que te puedo restaurar los datos
                        TIEMPO                                      v
.....................|----------------------------------------------|...X
                     ^                                                  ^
                     Fecha más atrás del tiempo                         Ahora
                     donde garantizo restauración                            
                        2 semanas, 1 mes, 1 semana

Estado en la que necesito la BBDD para hacer un determinado procedimiento de BACKUPS:
- Frio:         Paro BBDD / Me quedo sin servicio. Con que frecuencia
- Caliente:     Seguir con la BBDD dando servicio

Tiempo de indisponibilidad del servicio asumible en caso de catastrofe.

Tenemos 2 grandes estrategias:
- Backup lógicos: Extraer los datos y llevarlos a unos ficheros         (EXPORT)
    Inconveniente:  Tarda mucho!
    Ventaja:        Puedo llevar los datos a otros sistema con facilidad.

        pg_dump    -U usuario -F(Tipo de fichero) -f FICHERO    BBDD        TABLA
            Podemos trabajar solo con bases de datos o tablas concretas
        pg_dumpall -U usuario -F(Tipo de fichero) -f FICHERO
                                    -Fp sql
                                    -Ft tar
            Trabajo a nivel de instancia (incluye permisos, usuarios....)
        Estos los hacemos en caliente sin problema de consistencia de datos.

        RESTORE:
            psql -U ..... < fichero.sql
            pg_restore -U usuario -d bbdd fichero (sql, tar)

- Backup físicos: Copiar los ficheros de la BBDD
    Ventaja:        Tarda mucho menos!
    Inconveniente:  No tengo los datos en bruto... tengo una copia de un fichero de BBDD...
                    Que la podré llevar a otro sistema IGUAL que este

    FRIO:
        No hay problema. Es lo más sencillo y rápido de todo:
            cp de la carpeta data
            rsync
    CALIENTE:
        Lo primero que necesito es TENER LA BBDD en modo WAL:
            - Primero: Los propios archivos WAL son mi copia de seguridad (INCREMENTAL, desde un momento dado del tiempo)
            - SEGUNDO: necesito una copia de seguridad que pueda restaurar para a partir de ella aplicar los WAL.
                    Teniendo el previo  pg_basebackup -Stream -> Copiar los archivos de WAL *
                                        pg_wal_replay          -> Restaurar los archivos de WAL
                    De esos ficheros de WAL tengo que hacer backup/copia <-- esto suele ser menos necesario *
                        Con independencia de las copias de seguridad, los archivos es muy complejo perderlos.

                    Los archivos de la BBDD (tablas) tienen modificaciones dentro del archivo en cualquier sitio < ACCESO ALEATORIO
                    Los archivos WAL solo sufren añadidos al final del fichero < ACCESO SECUENCIAL 
                        Dia 1
                        Dia 2
                        Dia 3
                        Dia 4
                        ...
                        Dia 10
        También podemos hacer copia completa, no incremental. FISICA:

        PASO 1: select pg_start_backup('ID DE BK');
            Esa función, deja temporalmente de escribir datos en los ficheros de la BBDD, solo escribe en los WAL.
        PASO 2: copia física de los archivos de la BBDD
            cp, rsync, tar, zip (CARPETA DATA)
        PASO 3: select pg_stop_backup('ID DE BK');
            Esa función, vuelca los cambios pendientes de los ficheros WAL a los ficheros de la BBDD
            Y reactiva la escritura de los ficheros de BBDD

Tipo de backup:
- Total:
    Hago una copia completa, que puedo restaurar y dejar el sistema en estado X funcional
- Incremental:
    Hago copia de los datos que se hayan modificado desde un instante de tiempo. 
    Para restaurarlo necesito una copia de los datos en ese instante del tiempo.

El servidor de BBDD tendrá su almacenamiento, el que sea, pero limitado... a que lo dedico.
- Costará MUY CARO !

En un entorno de producción, en cuantos sitios diferentes guardamos un DATO? Mínimo 3
RAID 5

# Modo replicación

No tanto para HA, sino para: 
- backups
- repositorios que usar para consultas (externos, por la propia app)

1º Maestro
- Cambios oportunos en el fichero de configuración:
  - Activar WAL con la conf replicación
  - Crear un usuario de replicación:         CREATE USER replication
  - select * FROM pg_create_physical_replication_slot('NOMBRE de replica');     (1)
  - Backup FISICO para llevarlo a la replica
        pg_basebackup -D CARPETA_DESTINO \       Me la llevo a la replica como carpeta data
                      -S "NOMBRE de replica" \                                   (1)
                      -X stream \
                      -U replication
            Este comando nos genera un fichero postgres.auto.conf automaticamente
            Ese fichero lo pondremos en el replica.
            Dentro de ese archivo tenemos la configuración propia de la máquina de replicación
2º Esclavo
    - Copiar la carpeta data
    - Ahí tendré la misma postgres.conf del maestro
    - Tendré también el fichero postgres.auto.conf
  Arrancar



# Contenedores
IMAGEN  13.3 > 13.4 > 14.0
        <- Volumen de datos (carpeta data)